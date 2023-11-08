class ChangeTypeOfRecentEmissionsLevelAtASCORPathways < ActiveRecord::Migration[6.1]
  def change
    change_column :ascor_pathways, :recent_emission_level, :string
  end
end
