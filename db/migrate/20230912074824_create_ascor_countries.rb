class CreateASCORCountries < ActiveRecord::Migration[6.1]
  def change
    create_table :ascor_countries do |t|
      t.string :name, index: { unique: true }
      t.string :iso, index: { unique: true }
      t.string :region
      t.string :wb_lending_group
      t.string :fiscal_monitor_category

      t.timestamps
    end
  end
end
