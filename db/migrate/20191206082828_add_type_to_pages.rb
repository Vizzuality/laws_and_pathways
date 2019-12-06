class AddTypeToPages < ActiveRecord::Migration[6.0]
  Page = Class.new(ActiveRecord::Base)
  def up
    add_column :pages, :type, :string
    Page.connection.execute("UPDATE pages SET type='TPIPage'")
  end

  def down
    remove_column :pages, :type
  end
end
