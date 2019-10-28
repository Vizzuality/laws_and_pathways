class RemoveApproachToClimateChangeFromGeographies < ActiveRecord::Migration[5.2]
  def change
    remove_column :geographies, :approach_to_climate_change, :text
  end
end
