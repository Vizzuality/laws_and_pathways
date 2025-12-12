class CreateJoinTableIndustriesTPISectors < ActiveRecord::Migration[6.1]
  def up
    create_join_table :industries, :tpi_sectors do |t|
      t.index :industry_id
      t.index :tpi_sector_id
    end

    execute <<-SQL
      INSERT INTO industries_tpi_sectors (industry_id, tpi_sector_id)
      SELECT industry_id, id
      FROM tpi_sectors
      WHERE industry_id IS NOT NULL
    SQL

    remove_foreign_key :tpi_sectors, :industries
    remove_index :tpi_sectors, :industry_id
    remove_column :tpi_sectors, :industry_id
  end

  def down
    add_reference :tpi_sectors, :industry, foreign_key: true, index: true

    execute <<-SQL
      UPDATE tpi_sectors
      SET industry_id = (
        SELECT industry_id
        FROM industries_tpi_sectors
        WHERE industries_tpi_sectors.tpi_sector_id = tpi_sectors.id
        LIMIT 1
      )
    SQL

    drop_join_table :industries, :tpi_sectors
  end
end
