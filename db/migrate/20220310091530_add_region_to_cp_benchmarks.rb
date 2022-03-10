class AddRegionToCPBenchmarks < ActiveRecord::Migration[6.0]
  def change
    add_column :cp_benchmarks, :region, :string, null: false, default: 'Global'
  end
end
