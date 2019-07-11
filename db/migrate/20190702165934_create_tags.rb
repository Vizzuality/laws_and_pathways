class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :type, null: false

      t.timestamps
    end

    create_table :taggings do |t|
      t.references :tag, foreign_key: {on_delete: :cascade}, index: true
      t.references :taggable, polymorphic: true, index: true

      t.timestamps
    end

    add_index :tags, [:name, :type], unique: true
  end
end
