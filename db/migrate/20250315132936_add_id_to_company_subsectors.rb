class AddIdToCompanySubsectors < ActiveRecord::Migration[6.1]
  def change
    add_column :company_subsectors, :id, :primary_key
  end
end
