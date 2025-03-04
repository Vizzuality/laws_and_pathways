class AddCPAlignment2028ToCPAssessments < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_assessments, :cp_alignment_2028, :string
    add_column :cp_assessments, :cp_regional_alignment_2028, :string
  end
end
