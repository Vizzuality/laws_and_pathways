class CreateCPAssessments < ActiveRecord::Migration[5.2]
  def change
    create_table :cp_assessments do |t|
      t.references :company, foreign_key: {on_delete: :cascade}, index: true
      t.date :publication_date, null: false
      t.date :assessment_date
      t.jsonb :emissions
      t.text :assumptions

      t.timestamps
    end
  end
end
