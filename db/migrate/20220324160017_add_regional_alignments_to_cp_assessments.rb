class AddRegionalAlignmentsToCPAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :cp_assessments, :region, :string
    add_column :cp_assessments, :cp_regional_alignment_2025, :string
    add_column :cp_assessments, :cp_regional_alignment_2035, :string
    add_column :cp_assessments, :cp_regional_alignment_2050, :string
  end
end
