class AddFiscalYearAndAssessmentTypeToMQAssessments < ActiveRecord::Migration[6.1]
  def change
    add_column :mq_assessments, :fiscal_year, :string
    add_column :mq_assessments, :assessment_type, :string
  end
end
