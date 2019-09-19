class AddDiscardedAtToLitigations < ActiveRecord::Migration[5.2]
  def change
    add_column :litigations, :discarded_at, :datetime
    add_index :litigations, :discarded_at
  end
end
