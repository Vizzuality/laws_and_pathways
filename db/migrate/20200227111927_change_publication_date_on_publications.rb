class ChangePublicationDateOnPublications < ActiveRecord::Migration[6.0]
  def change
    change_column :publications, :publication_date, :datetime
    change_column :news_articles, :publication_date, :datetime
  end
end
