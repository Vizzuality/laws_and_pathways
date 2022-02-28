class AddUniqueIndexesToInstrumentsAndInstrumentTypes < ActiveRecord::Migration[6.0]
  def change
    add_index :instruments, [:name, :instrument_type_id], unique: true
    add_index :instrument_types, :name, unique: true
  end
end
