class AddMQFocusCompanyToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :mq_focus_company, :boolean, default: false, null: false
  end
end

