class CreateLitigations < ActiveRecord::Migration[5.2]
  def change
    create_table :litigations do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :citation_reference_number
      t.string :document_type
      t.references :location, foreign_key: {on_delete: :cascade}, index: true
      t.references :jurisdiction, foreign_key: {
                     on_delete: :cascade,
                     to_table: :locations
                   }, index: true
      t.text :summary
      t.text :core_objective

      t.timestamps
    end

    add_index :litigations, :document_type
    add_index :litigations, :slug, unique: true
  end
end
