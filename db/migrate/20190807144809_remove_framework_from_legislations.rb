class RemoveFrameworkFromLegislations < ActiveRecord::Migration[5.2]
  def change
    remove_column :legislations, :framework, :string
  end
end
