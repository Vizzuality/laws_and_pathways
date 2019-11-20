class AddParentToLegislations < ActiveRecord::Migration[6.0]
  def change
    add_reference :legislations, :parent, null: true
  end
end
