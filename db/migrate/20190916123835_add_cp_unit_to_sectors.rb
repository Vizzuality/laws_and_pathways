class AddCpUnitToSectors < ActiveRecord::Migration[5.2]
  def change
    add_column :sectors, :cp_unit, :text
  end
end
