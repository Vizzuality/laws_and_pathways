class CreateLitigationSides < ActiveRecord::Migration[5.2]
  def change
    create_table :litigation_sides do |t|
      t.references :litigation, foreign_key: {on_delete: :cascade}, index: true
      t.string :name
      t.string :side_type, null: false
      t.string :party_type

      t.timestamps
    end
  end
end
