class RemoveIsinIndexFromCompanies < ActiveRecord::Migration[6.0]
  def change
    remove_index :companies, :isin
  end
end
