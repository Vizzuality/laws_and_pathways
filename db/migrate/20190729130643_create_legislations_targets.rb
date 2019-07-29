class CreateLegislationsTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :legislations_targets do |t|
      t.belongs_to :legislation, foreign_key: {on_delete: :cascade}
      t.belongs_to :target, foreign_key: {on_delete: :cascade}

      t.index [:target_id, :legislation_id], unique: true
    end
  end
end
