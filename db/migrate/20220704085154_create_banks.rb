class CreateBanks < ActiveRecord::Migration[6.0]
  def change
    create_table :banks do |t|
      t.references :geography, foreign_key: true, index: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :isin, null: false
      t.string :sedol
      t.string :market_cap_group

      t.timestamps
    end

    add_index :banks, :slug, unique: true
    add_index :banks, :name, unique: true
  end
end
