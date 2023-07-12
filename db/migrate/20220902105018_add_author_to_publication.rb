class AddAuthorToPublication < ActiveRecord::Migration[6.0]
  def change
    add_column :publications, :author, :string
  end
end
