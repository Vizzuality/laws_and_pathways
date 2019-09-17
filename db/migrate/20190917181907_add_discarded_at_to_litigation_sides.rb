class AddDiscardedAtToLitigationSides < ActiveRecord::Migration[5.2]
  def change
    add_column :litigation_sides, :discarded_at, :datetime
    add_index :litigation_sides, :discarded_at
  end
end
