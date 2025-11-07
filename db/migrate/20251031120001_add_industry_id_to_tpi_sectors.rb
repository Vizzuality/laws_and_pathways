class AddIndustryIdToTPISectors < ActiveRecord::Migration[6.1]
  def change
    add_reference :tpi_sectors, :industry, foreign_key: true, index: true
  end
end

