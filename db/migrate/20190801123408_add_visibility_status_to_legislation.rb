class AddVisibilityStatusToLegislation < ActiveRecord::Migration[5.2]
  def change
    add_column :legislations, :visibility_status, :string, index: true
  end
end
