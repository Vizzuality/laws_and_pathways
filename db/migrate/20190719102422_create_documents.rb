class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.text :external_url
      t.string :language
      t.date :last_verified_on
      t.references :documentable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
