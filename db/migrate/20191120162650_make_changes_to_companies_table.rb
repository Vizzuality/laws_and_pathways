class MakeChangesToCompaniesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :sedol, :integer
    add_column :companies, :latest_information, :text
    add_column :companies, :historical_comments, :text
    rename_column :companies, :size, :market_cap_group
  end
end
