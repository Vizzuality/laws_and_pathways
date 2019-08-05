class AddVisibilityStatusToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :visibility_status, :string, index: true, default: "draft"
  end
end
