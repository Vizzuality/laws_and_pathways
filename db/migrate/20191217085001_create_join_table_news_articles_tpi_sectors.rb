class CreateJoinTableNewsArticlesTPISectors < ActiveRecord::Migration[6.0]
  def change
    remove_column :news_articles, :sector_id, :bigint
    create_join_table :news_articles, :tpi_sectors do |t|
      t.index :news_article_id
      t.index :tpi_sector_id
    end
  end
end
