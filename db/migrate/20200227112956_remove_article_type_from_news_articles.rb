class RemoveArticleTypeFromNewsArticles < ActiveRecord::Migration[6.0]
  def change
    remove_column :news_articles, :article_type, :string
  end
end
