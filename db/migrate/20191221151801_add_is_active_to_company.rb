class AddIsActiveToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :is_active, :boolean, default: true
  end
end
