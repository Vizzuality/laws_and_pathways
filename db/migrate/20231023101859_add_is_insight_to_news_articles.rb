class AddIsInsightToNewsArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :news_articles, :is_insight, :boolean, default: false
  end
end
