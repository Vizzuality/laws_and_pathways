class AddCategoriesToSector < ActiveRecord::Migration[6.0]
  def change
    add_column :tpi_sectors, :categories, :string, array: true, default: []
    TPISector.reset_column_information
    TPISector.update_all categories: ["Company"]
  end
end
