class AddPermidToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :permid, :string
  end
end

