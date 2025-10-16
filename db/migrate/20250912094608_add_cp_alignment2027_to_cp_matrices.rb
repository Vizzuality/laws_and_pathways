class AddCPAlignment2027ToCPMatrices < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_matrices, :cp_alignment_2027, :string
  end
end
