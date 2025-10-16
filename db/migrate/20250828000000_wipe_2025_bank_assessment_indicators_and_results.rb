class Wipe2025BankAssessmentIndicatorsAndResults < ActiveRecord::Migration[6.1]
  def up
    puts "Starting to wipe 2025 bank assessment indicators and results..."
    
    # First, delete all BankAssessmentResults that reference 2025 active indicators
    results_to_delete = BankAssessmentResult.joins(:indicator)
                                          .where(bank_assessment_indicators: { version: '2025', active: true })
    
    results_count = results_to_delete.count
    puts "Found #{results_count} assessment results to delete"
    
    if results_count > 0
      results_to_delete.delete_all
      puts "Deleted #{results_count} assessment results"
    end
    
    # Then, delete all 2025 active indicators
    indicators_to_delete = BankAssessmentIndicator.where(version: '2025', active: true)
    
    indicators_count = indicators_to_delete.count
    puts "Found #{indicators_count} indicators to delete"
    
    if indicators_count > 0
      indicators_to_delete.delete_all
      puts "Deleted #{indicators_count} indicators"
    end
    
    puts "Migration completed successfully"
  end

  def down
    puts "This migration cannot be reversed as it permanently deletes data"
    raise ActiveRecord::IrreversibleMigration, "Cannot reverse data deletion"
  end
end
