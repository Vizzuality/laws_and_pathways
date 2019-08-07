class AddCreatedByAndUpdatedByToLegislations < ActiveRecord::Migration[5.2]
  def change
    add_reference :legislations, :created_by, foreign_key: { to_table: :admin_users }, index: true
    add_reference :legislations, :updated_by, foreign_key: { to_table: :admin_users }, index: true
  end
end
