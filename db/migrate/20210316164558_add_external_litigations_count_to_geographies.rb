class AddExternalLitigationsCountToGeographies < ActiveRecord::Migration[6.0]
  def change
    add_column :geographies, :external_litigations_count, :integer, default: 0
  end
end
