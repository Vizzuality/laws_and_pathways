class Add2030AlignmentToCPMatrices < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_matrices, :cp_alignment_2030, :string
  end
end
