class CreateBankAssessmentIndicators < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_assessment_indicators do |t|
      t.string :indicator_type, null: false
      t.string :number, null: false
      t.text :text, null: false

      t.timestamps
    end

    add_index :bank_assessment_indicators, [:indicator_type, :number], unique: true
  end
end
