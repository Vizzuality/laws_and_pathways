class AddSourceToCPBenchmark < ActiveRecord::Migration[6.0]
  def change
    add_column :cp_benchmarks, :source, :string, null: true
    CP::Benchmark.update_all source: 'Company'
    change_column_null :cp_benchmarks, :source, false
  end
end
