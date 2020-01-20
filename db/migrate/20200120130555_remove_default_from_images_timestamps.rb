class RemoveDefaultFromImagesTimestamps < ActiveRecord::Migration[6.0]
  def change
    change_column_default :images, :created_at, nil
    change_column_default :images, :updated_at, nil
  end
end
