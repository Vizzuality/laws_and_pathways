class CreateASCORAssessmentResults < ActiveRecord::Migration[6.1]
  def change
    create_table :ascor_assessment_results do |t|
      t.references :assessment, null: false, foreign_key: { to_table: :ascor_assessments }
      t.references :indicator, null: false, foreign_key: { to_table: :ascor_assessment_indicators }
      t.string :answer, null: true
      t.string :source_name, null: true
      t.string :source_date, null: true
      t.string :source_link, null: true

      t.timestamps
    end

    add_index :ascor_assessment_results, [:assessment_id, :indicator_id], unique: true, name: 'assessment_results_on_assessment_id_and_indicator_id'
  end
end
