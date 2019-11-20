class AddParentToLegislations < ActiveRecord::Migration[6.0]
  def change
    add_column :legislations, :parent_id, :integer
    add_reference :legislations, :legislations, column: :parent_id,
      null: true, foreign_key: true
  end
end
