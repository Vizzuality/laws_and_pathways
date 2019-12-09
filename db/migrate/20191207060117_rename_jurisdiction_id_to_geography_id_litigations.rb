class RenameJurisdictionIdToGeographyIdLitigations < ActiveRecord::Migration[6.0]
  def change
    rename_column :litigations, :jurisdiction_id, :geography_id
    add_column :litigations, :jurisdiction, :string
  end
end
