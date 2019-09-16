class AddDiscardedAtToGeographies < ActiveRecord::Migration[5.2]
  def change
    add_column :geographies, :discarded_at, :datetime
    add_index :geographies, :discarded_at
  end
end
