class CreatePublications < ActiveRecord::Migration[6.0]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :short_description
      t.bigint :file
      t.bigint :thumbnail
      t.date :publication_date
      t.references :created_by, foreign_key: { to_table: :admin_users }
      t.references :updated_by, foreign_key: { to_table: :admin_users }

      t.timestamps
    end
  end
end
