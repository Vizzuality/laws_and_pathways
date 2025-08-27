namespace :bank_assessment_data do
  desc 'Backup existing bank assessment indicators and responses'
  task backup: :environment do
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_dir = Rails.root.join('db', 'backups', 'bank_assessment_data')
    FileUtils.mkdir_p(backup_dir)

    puts 'Starting backup of bank assessment data...'

    # Backup indicators
    indicators_file = backup_dir.join("bank_assessment_indicators_#{timestamp}.csv")
    puts "Backing up indicators to #{indicators_file}..."

    CSV.open(indicators_file, 'w') do |csv|
      csv << ['Id', 'Type', 'Number', 'Text', 'Comment', 'Is Placeholder', 'Created At', 'Updated At']

      BankAssessmentIndicator.order(:indicator_type, :number).each do |indicator|
        csv << [
          indicator.id,
          indicator.indicator_type,
          indicator.number,
          indicator.text,
          indicator.comment,
          indicator.is_placeholder,
          indicator.created_at,
          indicator.updated_at
        ]
      end
    end

    puts "Backed up #{BankAssessmentIndicator.count} indicators"

    # Backup assessment results
    results_file = backup_dir.join("bank_assessment_results_#{timestamp}.csv")
    puts "Backing up assessment results to #{results_file}..."

    CSV.open(results_file, 'w') do |csv|
      csv << ['Id', 'Bank Assessment Id', 'Bank Assessment Indicator Id', 'Answer', 'Percentage', 'Created At', 'Updated At']

      BankAssessmentResult.includes(:assessment, :indicator).each do |result|
        csv << [
          result.id,
          result.bank_assessment_id,
          result.bank_assessment_indicator_id,
          result.answer,
          result.percentage,
          result.created_at,
          result.updated_at
        ]
      end
    end

    puts "Backed up #{BankAssessmentResult.count} assessment results"

    # Create a metadata file
    metadata_file = backup_dir.join("backup_metadata_#{timestamp}.json")
    metadata = {
      backup_timestamp: timestamp,
      indicators_count: BankAssessmentIndicator.count,
      results_count: BankAssessmentResult.count,
      banks_count: Bank.count,
      bank_assessments_count: BankAssessment.count,
      created_at: Time.current.iso8601
    }

    File.write(metadata_file, JSON.pretty_generate(metadata))
    puts "Backup metadata saved to #{metadata_file}"

    puts 'Backup completed successfully!'
    puts "Backup directory: #{backup_dir}"
    puts 'Files created:'
    puts "  - #{indicators_file.basename}"
    puts "  - #{results_file.basename}"
    puts "  - #{metadata_file.basename}"
  end

  desc 'List available backups'
  task list_backups: :environment do
    backup_dir = Rails.root.join('db', 'backups', 'bank_assessment_data')

    if Dir.exist?(backup_dir)
      backups = Dir.glob(backup_dir.join('backup_metadata_*.json')).sort.reverse

      if backups.any?
        puts 'Available backups:'
        backups.each do |metadata_file|
          metadata = JSON.parse(File.read(metadata_file))
          timestamp = metadata['backup_timestamp']
          created_at = metadata['created_at']
          indicators_count = metadata['indicators_count']
          results_count = metadata['results_count']

          puts "  #{timestamp} (#{created_at}) - #{indicators_count} indicators, #{results_count} results"
        end
      else
        puts "No backups found in #{backup_dir}"
      end
    else
      puts "Backup directory does not exist: #{backup_dir}"
    end
  end

  desc 'Restore bank assessment data from backup'
  task :restore, [:timestamp] => :environment do |_task, args|
    if args[:timestamp].blank?
      puts 'Usage: rails bank_assessment_data:restore[TIMESTAMP]'
      puts 'Example: rails bank_assessment_data:restore[20250825_143022]'
      puts "\nAvailable backups:"
      Rake::Task['bank_assessment_data:list_backups'].invoke
      exit
    end

    timestamp = args[:timestamp]
    backup_dir = Rails.root.join('db', 'backups', 'bank_assessment_data')

    indicators_file = backup_dir.join("bank_assessment_indicators_#{timestamp}.csv")
    results_file = backup_dir.join("bank_assessment_results_#{timestamp}.csv")
    metadata_file = backup_dir.join("backup_metadata_#{timestamp}.json")

    unless File.exist?(indicators_file) && File.exist?(results_file) && File.exist?(metadata_file)
      puts "Error: Backup files not found for timestamp #{timestamp}"
      puts 'Expected files:'
      puts "  - #{indicators_file}"
      puts "  - #{results_file}"
      puts "  - #{metadata_file}"
      exit 1
    end

    puts "Starting restoration from backup #{timestamp}..."

    # Read metadata
    metadata = JSON.parse(File.read(metadata_file))
    puts "Backup contains: #{metadata['indicators_count']} indicators, #{metadata['results_count']} results"

    # Confirm restoration
    print 'This will overwrite current data. Are you sure? (yes/no): '
    confirmation = $stdin.gets.chomp.downcase

    unless confirmation == 'yes'
      puts 'Restoration cancelled.'
      exit
    end

    # Clear current data
    puts 'Clearing current data...'
    BankAssessmentResult.delete_all
    BankAssessmentIndicator.delete_all
    puts 'Current data cleared.'

    # Restore indicators
    puts 'Restoring indicators...'
    indicators_restored = 0

    CSV.foreach(indicators_file, headers: true) do |row|
      indicator = BankAssessmentIndicator.new(
        id: row['Id'].to_i,
        indicator_type: row['Type'],
        number: row['Number'],
        text: row['Text'],
        comment: row['Comment'],
        is_placeholder: row['Is Placeholder'] == 'true',
        created_at: row['Created At'],
        updated_at: row['Updated At']
      )

      if indicator.save
        indicators_restored += 1
        print '.' if (indicators_restored % 10).zero?
      else
        puts "\nError restoring indicator #{row['Number']}: #{indicator.errors.full_messages.join(', ')}"
      end
    end

    puts "\nRestored #{indicators_restored} indicators"

    # Restore results
    puts 'Restoring assessment results...'
    results_restored = 0

    CSV.foreach(results_file, headers: true) do |row|
      result = BankAssessmentResult.new(
        id: row['Id'].to_i,
        bank_assessment_id: row['Bank Assessment Id'].to_i,
        bank_assessment_indicator_id: row['Bank Assessment Indicator Id'].to_i,
        answer: row['Answer'],
        percentage: row['Percentage'].present? ? row['Percentage'].to_f : nil,
        created_at: row['Created At'],
        updated_at: row['Updated At']
      )

      if result.save
        results_restored += 1
        print '.' if (results_restored % 50).zero?
      else
        puts "\nError restoring result #{row['Id']}: #{result.errors.full_messages.join(', ')}"
      end
    end

    puts "\nRestored #{results_restored} assessment results"

    puts "\nRestoration completed successfully!"
    puts "Current data: #{BankAssessmentIndicator.count} indicators, #{BankAssessmentResult.count} results"
  end

  desc 'Show backup directory info'
  task info: :environment do
    backup_dir = Rails.root.join('db', 'backups', 'bank_assessment_data')

    puts "Backup directory: #{backup_dir}"

    if Dir.exist?(backup_dir)
      total_size = Dir.glob(backup_dir.join('**', '*')).select { |f| File.file?(f) }.sum { |f| File.size(f) }
      backup_count = Dir.glob(backup_dir.join('backup_metadata_*.json')).count

      puts 'Directory exists: Yes'
      puts "Total backups: #{backup_count}"
      puts "Total size: #{total_size} bytes (#{(total_size / 1024.0).round(2)} KB)"
    else
      puts 'Directory exists: No'
    end
  end
end
