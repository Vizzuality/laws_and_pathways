class CreateNewsArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :news_articles do |t|
      t.string :title
      t.text :content
      t.date :publication_date
      t.references :created_by, foreign_key: { to_table: :admin_users }
      t.references :updated_by, foreign_key: { to_table: :admin_users }

      t.timestamps
    end
  end
end
