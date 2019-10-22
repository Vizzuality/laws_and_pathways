class RenameSectorsToTpiSectors < ActiveRecord::Migration[5.2]
  def change
    rename_table :sectors, :tpi_sectors
  end
end
