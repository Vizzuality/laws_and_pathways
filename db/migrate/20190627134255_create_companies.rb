class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.references :location, foreign_key: true, index: true
      t.references :headquarter_location, foreign_key: {
                     to_table: :locations
                   }, index: true
      t.references :sector, foreign_key: true, index: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :isin, null: false
      t.string :size
      t.boolean :ca100, null: false, default: false

      t.timestamps
    end

    add_index :companies, :size
    add_index :companies, :slug, unique: true
    add_index :companies, :isin, unique: true
  end
end
