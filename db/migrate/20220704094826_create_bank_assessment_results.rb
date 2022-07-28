class CreateBankAssessmentResults < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_assessment_results do |t|
      t.references :bank_assessment, foreign_key: true, index: true
      t.references :bank_assessment_indicator, foreign_key: true, index: true

      t.string :answer
      t.float :percentage

      t.timestamps
    end
  end
end
