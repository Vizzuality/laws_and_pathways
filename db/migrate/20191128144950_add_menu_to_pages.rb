class AddMenuToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :menu, :string
  end
end
