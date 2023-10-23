class CreateASCORAssessments < ActiveRecord::Migration[6.1]
  def change
    create_table :ascor_assessments do |t|
      t.references :country, null: false, foreign_key: { to_table: :ascor_countries }
      t.date :assessment_date
      t.date :publication_date, null: true
      t.text :research_notes, null: true
      t.text :further_information, null: true

      t.timestamps
    end
  end
end
