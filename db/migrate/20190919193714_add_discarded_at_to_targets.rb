class AddDiscardedAtToTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :discarded_at, :datetime
    add_index :targets, :discarded_at
  end
end
