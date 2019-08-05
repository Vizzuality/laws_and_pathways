class AddVisibilityStatusToTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :visibility_status, :string, index: true, default: 'draft'
  end
end
