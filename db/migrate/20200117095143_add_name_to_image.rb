class AddNameToImage < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :name, :string
  end
end
