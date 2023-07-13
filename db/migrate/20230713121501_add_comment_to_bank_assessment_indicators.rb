class AddCommentToBankAssessmentIndicators < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_assessment_indicators, :comment, :text
  end
end
