class AddCPAlignmentToCPAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :cp_assessments, :cp_alignment, :string
  end
end
