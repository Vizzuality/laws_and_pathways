class AddTypeToContents < ActiveRecord::Migration[6.0]
  def change
    add_column :contents, :content_type, :string
  end
end
