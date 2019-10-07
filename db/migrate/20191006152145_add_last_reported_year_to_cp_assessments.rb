class AddLastReportedYearToCpAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :cp_assessments, :last_reported_year, :integer
  end
end
