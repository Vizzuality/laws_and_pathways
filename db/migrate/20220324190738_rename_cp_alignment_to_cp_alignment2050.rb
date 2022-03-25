class RenameCPAlignmentToCPAlignment2050 < ActiveRecord::Migration[6.0]
  def change
    rename_column :cp_assessments, :cp_alignment, :cp_alignment_2050
  end
end
