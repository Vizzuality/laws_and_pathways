class UpdateLegislations < ActiveRecord::Migration[5.2]
  def change
    add_column :legislations, :date_passed, :date
  end
end
