class AddAssessmentDateToASCORAssessmentIndicators < ActiveRecord::Migration[6.1]
  def change
    add_column :ascor_assessment_indicators, :assessment_date, :date
  end
end
