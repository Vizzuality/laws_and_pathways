class CreateASCORBenchmarks < ActiveRecord::Migration[6.1]
  def change
    create_table :ascor_benchmarks do |t|
      t.references :country, null: false, foreign_key: { to_table: :ascor_countries }
      t.date :publication_date, null: true
      t.string :emissions_metric
      t.string :emissions_boundary
      t.string :land_use
      t.string :units
      t.string :benchmark_type
      t.jsonb :emissions, default: {}

      t.timestamps
    end
  end
end
