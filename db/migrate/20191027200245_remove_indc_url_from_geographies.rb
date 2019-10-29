class RemoveIndcUrlFromGeographies < ActiveRecord::Migration[5.2]
  def change
    remove_column :geographies, :indc_url, :text
  end
end
