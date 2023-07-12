class RemoveCPAlignmentYearOverrideFromCPAssessments < ActiveRecord::Migration[6.0]
  def change
    remove_column :cp_assessments, :cp_alignment_year_override, :integer
  end
end
