class CreateCpBenchmarks < ActiveRecord::Migration[5.2]
  def change
    create_table :cp_benchmarks do |t|
      t.references :sector, foreign_key: {on_delete: :cascade}, index: true
      t.string :date
      t.boolean :current, null: false, default: false
      t.jsonb :benchmarks

      t.timestamps
    end
  end
end
