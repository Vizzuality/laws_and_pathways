class AddIsEventToNewsArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :news_articles, :is_event, :boolean, default: false
  end
end
