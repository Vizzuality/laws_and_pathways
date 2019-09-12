class AddDiscardedAtToLegislations < ActiveRecord::Migration[5.2]
  def change
    add_column :legislations, :discarded_at, :datetime
    add_index :legislations, :discarded_at
  end
end
