class CreateBankAssessments < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_assessments do |t|
      t.references :bank, foreign_key: {on_delete: :cascade}, index: true
      t.date :assessment_date, null: false
      t.text :notes

      t.timestamps
    end
  end
end
