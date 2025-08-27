class CreateSubsectors < ActiveRecord::Migration[6.1]
  def change
    create_table :subsectors do |t|
      t.references :sector, null: false, foreign_key: { to_table: :tpi_sectors }
      t.string :name, null: false
      t.timestamps
    end

    add_index :subsectors, [:sector_id, :name], unique: true
  end
end
