class AddVisibilityStatusToLitigation < ActiveRecord::Migration[5.2]
  def change
    add_column :litigations, :visibility_status, :string, index: true, default: 'draft'
  end
end
