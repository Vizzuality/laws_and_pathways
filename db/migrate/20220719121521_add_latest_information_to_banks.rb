class AddLatestInformationToBanks < ActiveRecord::Migration[6.0]
  def change
    add_column :banks, :latest_information, :text
  end
end
