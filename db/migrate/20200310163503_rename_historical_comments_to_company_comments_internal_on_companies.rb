class RenameHistoricalCommentsToCompanyCommentsInternalOnCompanies < ActiveRecord::Migration[6.0]
  def change
   rename_column :companies, :historical_comments, :company_comments_internal
  end
end
