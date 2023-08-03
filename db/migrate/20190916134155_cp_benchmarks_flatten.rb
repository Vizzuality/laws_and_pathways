class CPBenchmarksFlatten < ActiveRecord::Migration[5.2]
  def change
    remove_column :cp_benchmarks, :benchmarks, :jsonb
    add_column :cp_benchmarks, :emissions, :jsonb
    add_column :cp_benchmarks, :scenario, :string
    rename_column :cp_benchmarks, :date, :release_date
  end
end
