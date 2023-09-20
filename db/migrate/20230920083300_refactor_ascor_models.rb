class RefactorASCORModels < ActiveRecord::Migration[6.1]
  def change
    add_column :ascor_countries, :type_of_party, :string, null: true
    remove_column :ascor_benchmarks, :land_use
    add_column :ascor_assessment_indicators, :units_or_response_type, :string, null: true
  end
end
