class CreateMqAssessments < ActiveRecord::Migration[5.2]
  def change
    create_table :mq_assessments do |t|
      t.references :company, foreign_key: {on_delete: :cascade}, index: true
      t.string :level, null: false
      t.text :notes
      t.date :assessment_date, null: false
      t.date :publication_date, null: false
      t.jsonb :questions

      t.timestamps
    end
  end
end
