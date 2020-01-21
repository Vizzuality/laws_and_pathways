class AddYoutubeLinkToContent < ActiveRecord::Migration[6.0]
  def change
    add_column :contents, :youtube_link, :string
  end
end
