class AddIndexToLitigationSides < ActiveRecord::Migration[6.0]
  def change
    add_index :litigation_sides, [:litigation_id, :side_type, :name], unique: true
  end
end
