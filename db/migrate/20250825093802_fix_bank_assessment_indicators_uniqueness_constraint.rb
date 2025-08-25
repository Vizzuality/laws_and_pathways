class FixBankAssessmentIndicatorsUniquenessConstraint < ActiveRecord::Migration[6.1]
  def up
    # First, ensure the old constraint exists before trying to remove it
    if index_exists?(:bank_assessment_indicators, [:indicator_type, :number])
      remove_index :bank_assessment_indicators, [:indicator_type, :number]
    end
    
    # Add the new uniqueness constraint that includes version
    add_index :bank_assessment_indicators, [:indicator_type, :number, :version], 
              unique: true, 
              name: 'index_bank_assessment_indicators_on_type_number_version'
  end

  def down
    # Remove the new constraint
    remove_index :bank_assessment_indicators, name: 'index_bank_assessment_indicators_on_type_number_version'
    
    # Restore the old constraint
    add_index :bank_assessment_indicators, [:indicator_type, :number], unique: true
  end
end
