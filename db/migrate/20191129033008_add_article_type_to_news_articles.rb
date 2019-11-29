class AddArticleTypeToNewsArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :news_articles, :article_type, :string
  end
end
