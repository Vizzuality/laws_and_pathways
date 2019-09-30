class AddDiscardedAtToInstrumentType < ActiveRecord::Migration[5.2]
  def change
    add_column :instrument_types, :discarded_at, :datetime
    add_index :instrument_types, :discarded_at
  end
end
