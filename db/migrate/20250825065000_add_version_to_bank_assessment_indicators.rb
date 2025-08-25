class AddVersionToBankAssessmentIndicators < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_assessment_indicators, :version, :string, default: '2025'
    add_column :bank_assessment_indicators, :active, :boolean, default: true

    add_index :bank_assessment_indicators, [:version, :active]
    
    # Remove the old uniqueness constraint
    remove_index :bank_assessment_indicators, [:indicator_type, :number]
    
    # Add new uniqueness constraint that includes version
    add_index :bank_assessment_indicators, [:indicator_type, :number, :version], unique: true, name: 'index_bank_assessment_indicators_on_type_number_version'
  end
end
