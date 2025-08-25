class Add2030AlignmentsToCPAssessments < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_assessments, :cp_alignment_2030, :string
    add_column :cp_assessments, :cp_regional_alignment_2030, :string
  end
end
