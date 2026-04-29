class AddBenchmarkLabelToCPBenchmarks < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_benchmarks, :benchmark_label, :string
  end
end
