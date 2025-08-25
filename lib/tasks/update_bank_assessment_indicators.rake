namespace :bank_assessment_indicators do
  desc "Update bank assessment indicators with new structure"
  task update: :environment do
    puts "Starting bank assessment indicators update..."
    
    # Create backup first
    puts "Creating backup of current data..."
    Rake::Task['bank_assessment_data:backup'].invoke
    
    # Clear existing indicators
    puts "Clearing existing indicators..."
    BankAssessmentIndicator.delete_all
    puts "Deleted #{BankAssessmentIndicator.count} existing indicators"
    
    # Import new indicators
    puts "Importing new indicators..."
    csv_file = Rails.root.join('db', 'seeds', 'tpi', 'bank_assessment_indicators_new.csv')
    
    if File.exist?(csv_file)
      require 'csv'
      
      CSV.foreach(csv_file, headers: true, header_converters: :symbol) do |row|
        next if row[:type].blank? || row[:number].blank? || row[:text].blank?
        
        indicator = BankAssessmentIndicator.new(
          indicator_type: row[:type].downcase,
          number: row[:number],
          text: row[:text]
        )
        
        if indicator.save
          puts "Created: #{indicator.indicator_type} #{indicator.number} - #{indicator.text}"
        else
          puts "Error creating #{row[:type]} #{row[:number]}: #{indicator.errors.full_messages.join(', ')}"
        end
      end
      
      puts "Import completed. Total indicators: #{BankAssessmentIndicator.count}"
      puts "\nIMPORTANT: A backup was created before this update."
      puts "If you need to restore the previous data, use:"
      puts "  rails bank_assessment_data:list_backups"
      puts "  rails bank_assessment_data:restore[TIMESTAMP]"
    else
      puts "Error: CSV file not found at #{csv_file}"
    end
  end
  
  desc "Show current bank assessment indicators count"
  task count: :environment do
    puts "Current bank assessment indicators:"
    BankAssessmentIndicator.group(:indicator_type).count.each do |type, count|
      puts "  #{type}: #{count}"
    end
    puts "Total: #{BankAssessmentIndicator.count}"
  end
  
  desc "Preview new indicators structure without applying changes"
  task preview: :environment do
    puts "Previewing new indicators structure..."
    csv_file = Rails.root.join('db', 'seeds', 'tpi', 'bank_assessment_indicators_new.csv')
    
    if File.exist?(csv_file)
      require 'csv'
      
      current_count = BankAssessmentIndicator.count
      new_count = 0
      
      puts "\nNew structure preview:"
      puts "=" * 80
      
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
      
      puts "=" * 80
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
end
