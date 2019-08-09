class RenameLocationsToGeographies < ActiveRecord::Migration[5.2]
  def change
    # table rename
    rename_table :locations, :geographies
    rename_column :geographies, :location_type, :geography_type

    # foreign_keys rename
    remove_index :companies, :location_id
    rename_column :companies, :location_id, :geography_id
    add_index :companies, :geography_id

    remove_index :companies, :headquarter_location_id
    rename_column :companies, :headquarter_location_id, :headquarters_geography_id
    add_index :companies, :headquarters_geography_id

    remove_index :legislations, :location_id
    rename_column :legislations, :location_id, :geography_id
    add_index :legislations, :geography_id

    remove_index :litigations, :location_id
    rename_column :litigations, :location_id, :geography_id
    add_index :litigations, :geography_id

    remove_index :targets, :location_id
    rename_column :targets, :location_id, :geography_id
    add_index :targets, :geography_id
  end
end
