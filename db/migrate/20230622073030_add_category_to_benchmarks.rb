class AddCategoryToBenchmarks < ActiveRecord::Migration[6.0]
  def change
    add_column :cp_benchmarks, :category, :string, null: true
    CP::Benchmark.update_all category: 'Company'
    change_column_null :cp_benchmarks, :category, false
  end
end
