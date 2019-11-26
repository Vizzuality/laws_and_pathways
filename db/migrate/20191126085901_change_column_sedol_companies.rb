class ChangeColumnSedolCompanies < ActiveRecord::Migration[6.0]
  def change
    change_column :companies, :sedol, :string
  end
end
