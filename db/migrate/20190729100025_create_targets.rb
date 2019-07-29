class CreateTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :targets do |t|
      t.belongs_to :location, foreign_key: true, index: true
      t.belongs_to :sector, foreign_key: true, index: true
      t.boolean :ghg_target, null: false, default: false
      t.string :type, null: false
      t.text :description
      t.integer :year
      t.string :base_year_period

      t.timestamps
    end
  end
end
