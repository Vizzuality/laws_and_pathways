class AddPositionToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :position, :integer
  end
end
