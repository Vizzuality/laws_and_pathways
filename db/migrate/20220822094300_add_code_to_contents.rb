class AddCodeToContents < ActiveRecord::Migration[6.0]
  def change
    add_column :contents, :code, :string
  end
end
