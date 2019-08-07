class AddCreatedByAndUpdatedByToLocations < ActiveRecord::Migration[5.2]
  def change
    add_reference :locations, :created_by, foreign_key: { to_table: :admin_users }, index: true
    add_reference :locations, :updated_by, foreign_key: { to_table: :admin_users }, index: true
  end
end
