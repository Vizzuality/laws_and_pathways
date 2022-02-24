class Add2025And2035AlignmentsAndTargetYearsToCPAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :cp_assessments, :cp_alignment_2025, :string
    add_column :cp_assessments, :cp_alignment_2035, :string
    add_column :cp_assessments, :years_with_targets, :integer, array: true
  end
end
