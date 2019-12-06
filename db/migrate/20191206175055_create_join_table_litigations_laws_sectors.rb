class CreateJoinTableLitigationsLawsSectors < ActiveRecord::Migration[6.0]
  def change
    remove_column :litigations, :sector_id, :bigint
    create_join_table :litigations, :laws_sectors do |t|
      t.index :litigation_id
      t.index :laws_sector_id
    end
  end
end
