class CreateJoinTableLegislationLawsSectors < ActiveRecord::Migration[6.0]
  def change
    remove_column :legislations, :sector_id
    create_join_table :legislations, :laws_sectors do |t|
      t.index :legislation_id
      t.index :laws_sector_id
    end
  end
end
