class AddVersionToBankAssessmentIndicators < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_assessment_indicators, :version, :string, default: '2025'
    add_column :bank_assessment_indicators, :active, :boolean, default: true
    
    add_index :bank_assessment_indicators, [:version, :active]
  end
end
