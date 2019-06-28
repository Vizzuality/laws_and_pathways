class CreateSectors < ActiveRecord::Migration[5.2]
  def change
    create_table :sectors do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :sectors, :name, unique: true
    add_index :sectors, :slug, unique: true
  end
end
