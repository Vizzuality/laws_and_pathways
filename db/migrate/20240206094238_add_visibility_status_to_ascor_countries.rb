class AddVisibilityStatusToASCORCountries < ActiveRecord::Migration[6.1]
  def change
    add_column :ascor_countries, :visibility_status, :string, index: true, default: 'draft'
    ASCOR::Country.update_all visibility_status: 'published'
  end
end
