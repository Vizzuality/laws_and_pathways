class RenameThumbnailToImageInPublications < ActiveRecord::Migration[6.0]
  def change
    rename_column :publications, :thumbnail, :image
  end
end
