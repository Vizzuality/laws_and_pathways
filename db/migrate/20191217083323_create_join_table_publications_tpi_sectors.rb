class CreateJoinTablePublicationsTPISectors < ActiveRecord::Migration[6.0]
  def change
    remove_column :publications, :sector_id, :bigint
    create_join_table :publications, :tpi_sectors do |t|
      t.index :publication_id
      t.index :tpi_sector_id
    end
  end
end
