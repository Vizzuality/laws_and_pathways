class RenameGovernancesToThemes < ActiveRecord::Migration[6.0]
  def change
    rename_table :governance_types, :theme_types
    rename_table :governances, :themes
    rename_column :themes, :governance_type_id, :theme_type_id

    rename_table :governances_legislations, :legislations_themes
    rename_column :legislations_themes, :governance_id, :theme_id
  end
end
