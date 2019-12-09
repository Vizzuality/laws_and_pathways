class RemoveDatePassedFromLegislations < ActiveRecord::Migration[6.0]
  def change
    remove_column :legislations, :date_passed, :date
  end
end
