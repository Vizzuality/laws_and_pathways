class AddIndcUrlToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :indc_url, :text
  end
end
