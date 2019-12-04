class AddTPISectorIdToPublicationsAndNews < ActiveRecord::Migration[6.0]
  def change
    add_reference :publications, :sector, foreign_key: { to_table: :tpi_sectors }
    add_reference :news_articles, :sector, foreign_key: { to_table: :tpi_sectors }
  end
end
