class AddDiscardedAtToInstrument < ActiveRecord::Migration[5.2]
  def change
    add_column :instruments, :discarded_at, :datetime
    add_index :instruments, :discarded_at
  end
end
