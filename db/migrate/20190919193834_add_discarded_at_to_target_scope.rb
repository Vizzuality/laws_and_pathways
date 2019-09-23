class AddDiscardedAtToTargetScope < ActiveRecord::Migration[5.2]
  def change
    add_column :target_scopes, :discarded_at, :datetime
    add_index :target_scopes, :discarded_at
  end
end
