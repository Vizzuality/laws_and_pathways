class AddPercentGlobalEmissionsAndClimateRiskIndexAndWbIncomeGroupToGeographies < ActiveRecord::Migration[6.0]
  def change
    add_column :geographies, :percent_global_emissions, :string
    add_column :geographies, :climate_risk_index, :string
    add_column :geographies, :wb_income_group, :string
  end
end
