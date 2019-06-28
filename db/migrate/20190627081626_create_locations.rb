class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.string :location_type, null: false
      t.string :iso, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.string :region, null: false
      t.boolean :federal, null: false, default: false
      t.text :federal_details
      t.text :approach_to_climate_change
      t.text :legislative_process

      t.timestamps
    end

    add_index :locations, :region
    add_index :locations, :slug, unique: true
    add_index :locations, :iso, unique: true
  end
end
