class AddDiscardedAtToGovernance < ActiveRecord::Migration[5.2]
  def change
    add_column :governances, :discarded_at, :datetime
    add_index :governances, :discarded_at
  end
end
