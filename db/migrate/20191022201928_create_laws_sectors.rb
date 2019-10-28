class CreateLawsSectors < ActiveRecord::Migration[5.2]
  def change
    create_table :laws_sectors do |t|
      t.string :name, null: false
      t.belongs_to :parent, foreign_key: { to_table: :laws_sectors }, index: true

      t.timestamps
    end

    add_index :laws_sectors, :name, unique: true

    remove_reference :targets, :sector, foreign_key: { to_table: :tpi_sectors }, index: true
    add_reference :targets, :sector, foreign_key: { to_table: :laws_sectors }, index: true

    add_reference :legislations, :sector, foreign_key: { to_table: :laws_sectors }, index: true
    add_reference :litigations, :sector, foreign_key: { to_table: :laws_sectors }, index: true
  end
end
