namespace :bank_assessment_indicators do
  desc 'Update bank assessment indicators with new structure (NON-SAFE MODE)'
  task update: :environment do
    puts 'Starting NON-SAFE bank assessment indicators update...'

    # Create backup first
    puts 'Creating backup of current data...'
    Rake::Task['bank_assessment_data:backup'].invoke

    # Check existing data
    existing_assessments = BankAssessment.count
    existing_results = BankAssessmentResult.count
    existing_indicators = BankAssessmentIndicator.count

    puts "\nCurrent data status:"
    puts "  - Bank assessments: #{existing_assessments}"
    puts "  - Assessment results: #{existing_results}"
    puts "  - Indicators: #{existing_indicators}"

    if existing_results > 0
      puts "\n⚠️  WARNING: You have #{existing_results} existing assessment results!"
      puts '   These will be orphaned if indicators are deleted.'
      puts "   Consider using the 'safe_update' task instead."

      print "\nDo you want to continue with the destructive update? (yes/no): "
      confirmation = STDIN.gets.chomp.downcase

      unless confirmation == 'yes'
        puts "Update cancelled. Use 'rails bank_assessment_indicators:safe_update' for a safer approach."
        exit
      end
    end

    # Clear existing indicators
    puts "\nClearing existing indicators..."
    BankAssessmentIndicator.delete_all
    puts "Deleted #{existing_indicators} existing indicators"

    # Import new indicators
    puts 'Importing new indicators...'
    csv_file = Rails.root.join('db', 'seeds', 'tpi', 'bank_assessment_indicators_new.csv')

    if File.exist?(csv_file)
      require 'csv'

      CSV.foreach(csv_file, headers: true, header_converters: :symbol) do |row|
        next if row[:type].blank? || row[:number].blank? || row[:text].blank?

        indicator = BankAssessmentIndicator.new(
          indicator_type: row[:type].downcase,
          number: row[:number],
          text: row[:text],
          version: '2025',
          active: true
        )

        if indicator.save
          puts "Created: #{indicator.indicator_type} #{indicator.number} - #{indicator.text}"
        else
          puts "Error creating #{row[:type]} #{row[:number]}: #{indicator.errors.full_messages.join(', ')}"
        end
      end

      puts "\nImport completed. Total indicators: #{BankAssessmentIndicator.count}"
      puts "\nIMPORTANT: A backup was created before this update."
      puts 'If you need to restore the previous data, use:'
      puts '  rails bank_assessment_data:list_backups'
      puts '  rails bank_assessment_data:restore[TIMESTAMP]'

      if existing_results > 0
        puts "\n⚠️  NOTE: #{existing_results} assessment results are now orphaned."
        puts '   You may need to clean them up or restore from backup.'
      end
    else
      puts "Error: CSV file not found at #{csv_file}"
    end
  end

  desc 'Update bank assessment indicators with new structure (SAFE MODE - preserves existing data)'
  task safe_update: :environment do
    puts 'Starting SAFE bank assessment indicators update...'

    # Create backup first
    puts 'Creating backup of current data...'
    Rake::Task['bank_assessment_data:backup'].invoke

    # Check existing data
    existing_assessments = BankAssessment.count
    existing_results = BankAssessmentResult.count
    existing_indicators = BankAssessmentIndicator.count

    puts "\nCurrent data status:"
    puts "  - Bank assessments: #{existing_assessments}"
    puts "  - Assessment results: #{existing_results}"
    puts "  - Indicators: #{existing_indicators}"

    if existing_results == 0
      puts "\nNo existing results found. Proceeding with normal update..."
      Rake::Task['bank_assessment_indicators:update'].invoke
      return
    end

    puts "\n🔒 SAFE MODE: Preserving existing data..."
    puts '✅ Using updated uniqueness constraint: [:indicator_type, :number, :version]'

    # Mark existing indicators as inactive
    puts 'Marking existing indicators as inactive...'
    BankAssessmentIndicator.update_all(active: false, version: '2024')
    puts "Marked #{existing_indicators} indicators as inactive"

    # Import new indicators with same numbering (now allowed with version constraint)
    puts 'Importing new indicators...'
    csv_file = Rails.root.join('db', 'seeds', 'tpi', 'bank_assessment_indicators_new.csv')

    if File.exist?(csv_file)
      require 'csv'

      new_indicators_created = 0

      CSV.foreach(csv_file, headers: true, header_converters: :symbol) do |row|
        next if row[:type].blank? || row[:number].blank? || row[:text].blank?

        indicator = BankAssessmentIndicator.new(
          indicator_type: row[:type].downcase,
          number: row[:number],
          text: row[:text],
          version: '2025',
          active: true
        )

        if indicator.save
          new_indicators_created += 1
          puts "Created: #{indicator.indicator_type} #{indicator.number} - #{indicator.text}"
        else
          puts "Error creating #{row[:type]} #{row[:number]}: #{indicator.errors.full_messages.join(', ')}"
        end
      end

      puts "\nSAFE update completed successfully!"
      puts "  - Old indicators: #{existing_indicators} (marked inactive, version 2024)"
      puts "  - New indicators: #{new_indicators_created} (active, version 2025)"
      puts "  - Existing results: #{existing_results} (preserved and accessible)"
      puts '  - ✅ Same numbering scheme preserved!'
      puts '  - ✅ Controllers now show only active indicators by default'

      puts "\nNext steps:"
      puts '  1. Test the new indicators work correctly'
      puts '  2. Verify that old and new indicators can coexist'
      puts '  3. Check that controllers show only active indicators'
      puts '  4. Consider migrating old results to new indicators if needed'
      puts '  5. Clean up old inactive indicators when ready'

    else
      puts "Error: CSV file not found at #{csv_file}"
    end
  end

  desc 'Update bank assessment indicators with new structure (SAFE MODE - alternative approach)'
  task safe_update_alt: :environment do
    puts 'Starting ALTERNATIVE SAFE bank assessment indicators update...'

    # Create backup first
    puts 'Creating backup of current data...'
    Rake::Task['bank_assessment_data:backup'].invoke

    # Check existing data
    existing_assessments = BankAssessment.count
    existing_results = BankAssessmentResult.count
    existing_indicators = BankAssessmentIndicator.count

    puts "\nCurrent data status:"
    puts "  - Bank assessments: #{existing_assessments}"
    puts "  - Assessment results: #{existing_results}"
    puts "  - Indicators: #{existing_indicators}"

    if existing_results == 0
      puts "\nNo existing results found. Proceeding with normal update..."
      Rake::Task['bank_assessment_indicators:update'].invoke
      return
    end

    puts "\n🔒 ALTERNATIVE SAFE MODE: Using different numbering scheme..."

    # This approach uses a different numbering scheme to avoid conflicts
    csv_file = Rails.root.join('db', 'seeds', 'tpi', 'bank_assessment_indicators_new.csv')

    if File.exist?(csv_file)
      require 'csv'

      # Mark existing indicators as inactive
      puts 'Marking existing indicators as inactive...'
      BankAssessmentIndicator.update_all(active: false, version: '2024')
      puts "Marked #{existing_indicators} indicators as inactive"

      # Import new indicators with modified numbering
      puts 'Importing new indicators with modified numbering...'
      new_indicators_created = 0

      CSV.foreach(csv_file, headers: true, header_converters: :symbol) do |row|
        next if row[:type].blank? || row[:number].blank? || row[:text].blank?

        # Modify numbering to avoid conflicts
        new_number = case row[:type].downcase
                     when 'area'
                       "A#{row[:number]}"
                     when 'indicator'
                       "I#{row[:number]}"
                     when 'sub_indicator'
                       "S#{row[:number]}"
                     else
                       "X#{row[:number]}"
                     end

        indicator = BankAssessmentIndicator.new(
          indicator_type: row[:type].downcase,
          number: new_number,
          text: row[:text],
          version: '2025',
          active: true
        )

        if indicator.save
          new_indicators_created += 1
          puts "Created: #{indicator.indicator_type} #{indicator.number} - #{indicator.text}"
        else
          puts "Error creating #{row[:type]} #{row[:number]}: #{indicator.errors.full_messages.join(', ')}"
        end
      end

      puts "\nAlternative safe update completed successfully!"
      puts "  - Old indicators: #{existing_indicators} (marked inactive, version 2024)"
      puts "  - New indicators: #{new_indicators_created} (active, version 2025, modified numbering)"
      puts "  - Existing results: #{existing_results} (preserved and accessible)"

      puts "\n⚠️  IMPORTANT: New indicators use modified numbering:"
      puts '   - Areas: A1, A2, A3... (instead of 1, 2, 3...)'
      puts '   - Indicators: I1.1, I1.2... (instead of 1.1, 1.2...)'
      puts '   - Sub-indicators: S1.1.a, S1.1.b... (instead of 1.1.a, 1.1.b...)'

      puts "\nNext steps:"
      puts '  1. Test the new indicators work correctly with modified numbering'
      puts '  2. Update application logic to handle the new numbering scheme'
      puts '  3. Consider if this numbering scheme is acceptable for your users'
      puts '  4. Clean up old inactive indicators when ready'

    else
      puts "Error: CSV file not found at #{csv_file}"
    end
  end

  desc 'Show current bank assessment indicators count'
  task count: :environment do
    puts 'Current bank assessment indicators:'
    BankAssessmentIndicator.group(:indicator_type, :version, :active).count.each do |(type, version, active), count|
      status = active ? 'ACTIVE' : 'INACTIVE'
      puts "  #{type} (v#{version}, #{status}): #{count}"
    end
    puts "Total: #{BankAssessmentIndicator.count}"

    puts "\nAssessment results status:"
    orphaned_results = BankAssessmentResult.left_joins(:indicator).where(bank_assessment_indicators: {id: nil}).count
    puts "  - Total results: #{BankAssessmentResult.count}"
    puts "  - Orphaned results: #{orphaned_results}"

    puts '  ⚠️  Some results are orphaned (no valid indicator)' if orphaned_results > 0
  end

  desc 'Preview new indicators structure without applying changes'
  task preview: :environment do
    puts 'Previewing new indicators structure...'
    csv_file = Rails.root.join('db', 'seeds', 'tpi', 'bank_assessment_indicators_new.csv')

    if File.exist?(csv_file)
      require 'csv'

      current_count = BankAssessmentIndicator.count
      new_count = 0

      puts "\nNew structure preview:"
      puts '=' * 80

      CSV.foreach(csv_file, headers: true, header_converters: :symbol) do |row|
        next if row[:type].blank? || row[:number].blank? || row[:text].blank?

        new_count += 1
        type = row[:type].downcase
        number = row[:number]
        text = row[:text]

        indent = case type
                 when 'area' then ''
                 when 'indicator' then '  '
                 when 'sub_indicator' then '    '
                 else '      '
                 end

        puts "#{indent}#{type.upcase} #{number}: #{text}"
      end

      puts '=' * 80
      puts "Current indicators: #{current_count}"
      puts "New indicators: #{new_count}"
      puts "Difference: #{new_count - current_count}"

      if new_count > current_count
        puts "\nThis update will ADD #{new_count - current_count} new indicators"
      elsif new_count < current_count
        puts "\nThis update will REMOVE #{current_count - new_count} existing indicators"
      else
        puts "\nThis update will REPLACE all indicators (same count)"
      end
    else
      puts "Error: CSV file not found at #{csv_file}"
    end
  end

  desc 'Clean up orphaned assessment results'
  task cleanup_orphaned_results: :environment do
    puts 'Checking for orphaned assessment results...'

    orphaned_results = BankAssessmentResult.left_joins(:indicator).where(bank_assessment_indicators: {id: nil})
    orphaned_count = orphaned_results.count

    if orphaned_count == 0
      puts 'No orphaned results found. All good!'
      return
    end

    puts "Found #{orphaned_count} orphaned results"

    print 'Do you want to delete these orphaned results? (yes/no): '
    confirmation = STDIN.gets.chomp.downcase

    if confirmation == 'yes'
      orphaned_results.delete_all
      puts "Deleted #{orphaned_count} orphaned results"
    else
      puts 'Cleanup cancelled. Orphaned results remain in database.'
    end
  end

  desc 'Reset indicators to original state (use after safe update)'
  task reset_to_original: :environment do
    puts 'Resetting indicators to original state...'

    # Check current status
    old_indicators = BankAssessmentIndicator.where(version: '2024').count
    new_indicators = BankAssessmentIndicator.where(version: '2025').count

    puts 'Current status:'
    puts "  - Old indicators (v2024): #{old_indicators}"
    puts "  - New indicators (v2025): #{new_indicators}"

    if old_indicators == 0
      puts 'No old indicators found to restore. Nothing to do.'
      return
    end

    print 'Do you want to restore old indicators and remove new ones? (yes/no): '
    confirmation = STDIN.gets.chomp.downcase

    if confirmation == 'yes'
      # Reactivate old indicators
      BankAssessmentIndicator.where(version: '2024').update_all(active: true)
      puts "Reactivated #{old_indicators} old indicators"

      # Remove new indicators
      BankAssessmentIndicator.where(version: '2025').delete_all
      puts "Removed #{new_indicators} new indicators"

      puts 'Reset completed successfully!'
    else
      puts 'Reset cancelled.'
    end
  end

  desc 'Create sample results for new indicators (for testing)'
  task create_sample_results: :environment do
    puts 'Creating sample results for new indicators...'

    # Get a bank assessment to work with
    assessment = BankAssessment.first

    if assessment.nil?
      puts 'No bank assessments found. Please create one first.'
      return
    end

    puts "Using assessment: #{assessment.bank.name} (#{assessment.assessment_date})"

    # Get active area indicators
    active_areas = BankAssessmentIndicator.active.where(indicator_type: 'area')

    if active_areas.empty?
      puts 'No active area indicators found.'
      return
    end

    puts "Found #{active_areas.count} active area indicators"

    # Create sample results for each area
    active_areas.each do |area|
      # Create a sample percentage result for the area
      result = BankAssessmentResult.find_or_initialize_by(
        assessment: assessment,
        indicator: area
      )

      if result.new_record?
        result.percentage = rand(20..80) # Random percentage between 20-80
        result.save!
        puts "Created sample result for #{area.indicator_type} #{area.number}: #{result.percentage}%"
      else
        puts "Result already exists for #{area.indicator_type} #{area.number}"
      end
    end

    puts "\nSample results created successfully!"
    puts "Total results for this assessment: #{assessment.results.count}"
    puts "Results with active indicators: #{assessment.results.joins(:indicator).where(bank_assessment_indicators: {active: true}).count}"
  end
end
