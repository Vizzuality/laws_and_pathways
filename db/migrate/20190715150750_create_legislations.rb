class CreateLegislations < ActiveRecord::Migration[5.2]
  def change
    create_table :legislations do |t|
      t.string :title
      t.text :description
      t.integer :law_id
      t.string :framework
      t.string :slug, null: false
      t.references :location, foreign_key: true

      t.timestamps
    end

    add_index :legislations, :slug, unique: true
  end
end
