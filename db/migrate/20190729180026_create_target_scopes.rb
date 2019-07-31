class CreateTargetScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :target_scopes do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
