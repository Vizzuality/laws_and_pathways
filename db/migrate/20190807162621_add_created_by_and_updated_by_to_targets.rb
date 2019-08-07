class AddCreatedByAndUpdatedByToTargets < ActiveRecord::Migration[5.2]
  def change
    add_reference :targets, :created_by, foreign_key: { to_table: :admin_users }, index: true
    add_reference :targets, :updated_by, foreign_key: { to_table: :admin_users }, index: true
  end
end
