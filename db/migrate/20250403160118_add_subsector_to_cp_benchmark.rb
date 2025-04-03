class AddSubsectorToCPBenchmark < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_benchmarks, :subsector, :string
    add_index  :cp_benchmarks, :subsector
  end
end
