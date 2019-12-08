class AddSourceToTargets < ActiveRecord::Migration[6.0]
  def change
    add_column :targets, :source, :string
  end
end
