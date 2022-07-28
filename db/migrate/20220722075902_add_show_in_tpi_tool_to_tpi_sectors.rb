class AddShowInTPIToolToTPISectors < ActiveRecord::Migration[6.0]
  def change
    add_column :tpi_sectors, :show_in_tpi_tool, :boolean, null: false, default: true
  end
end
