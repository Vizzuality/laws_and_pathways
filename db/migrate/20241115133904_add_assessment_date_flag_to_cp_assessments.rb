class AddAssessmentDateFlagToCPAssessments < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_assessments, :assessment_date_flag, :string
  end
end
