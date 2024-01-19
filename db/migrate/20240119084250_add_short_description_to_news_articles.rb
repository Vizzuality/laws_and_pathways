class AddShortDescriptionToNewsArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :news_articles, :short_description, :text
  end
end
