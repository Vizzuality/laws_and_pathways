class AddParentToLegislations < ActiveRecord::Migration[6.0]
  def change
    add_reference :legislations, :parent, foreign_key: { to_table: :legislations }, index: true, null: true
  end
end
