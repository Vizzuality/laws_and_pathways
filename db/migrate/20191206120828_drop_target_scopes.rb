class DropTargetScopes < ActiveRecord::Migration[6.0]
  def change
    remove_reference :targets, :target_scope
    drop_table :target_scopes
  end
end
