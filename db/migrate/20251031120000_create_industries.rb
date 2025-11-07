class CreateIndustries < ActiveRecord::Migration[6.1]
  def change
    create_table :industries do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :industries, :name, unique: true
    add_index :industries, :slug, unique: true
  end
end

