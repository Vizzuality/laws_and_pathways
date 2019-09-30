class CreateInstruments < ActiveRecord::Migration[5.2]
  def change
    create_table :instruments do |t|
      t.string :name
      t.references :instrument_type, foreign_key: true

      t.timestamps
    end
  end
end
