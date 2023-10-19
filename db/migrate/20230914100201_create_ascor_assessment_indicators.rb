class CreateASCORAssessmentIndicators < ActiveRecord::Migration[6.1]
  def change
    create_table :ascor_assessment_indicators do |t|
      t.string :indicator_type
      t.string :code
      t.text :text

      t.timestamps
    end
  end
end
