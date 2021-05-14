class AddCPAlignmentYearOverrideToCPAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :cp_assessments, :cp_alignment_year_override, :integer
  end
end
