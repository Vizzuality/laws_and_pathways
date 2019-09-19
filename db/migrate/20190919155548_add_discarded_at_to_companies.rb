class AddDiscardedAtToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :discarded_at, :datetime
    add_index :companies, :discarded_at
  end
end
