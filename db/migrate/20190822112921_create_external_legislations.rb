class CreateExternalLegislations < ActiveRecord::Migration[5.2]
  def change
    create_table :external_legislations do |t|
      t.string :name, null: false
      t.string :url
      t.references :geography, foreign_key: true

      t.timestamps
    end
  end
end
