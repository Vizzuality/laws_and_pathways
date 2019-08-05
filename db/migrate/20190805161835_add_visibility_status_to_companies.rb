class AddVisibilityStatusToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :visibility_status, :string, index: true, default: 'draft'
  end
end
