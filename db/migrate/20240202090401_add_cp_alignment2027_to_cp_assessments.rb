class AddCPAlignment2027ToCPAssessments < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_assessments, :cp_alignment_2027, :string
    add_column :cp_assessments, :cp_regional_alignment_2027, :string
  end
end
