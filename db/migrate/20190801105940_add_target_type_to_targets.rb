class AddTargetTypeToTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :target_type, :string
  end
end
