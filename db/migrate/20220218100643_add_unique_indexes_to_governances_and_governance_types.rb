class AddUniqueIndexesToGovernancesAndGovernanceTypes < ActiveRecord::Migration[6.0]
  def change
    add_index :governances, [:name, :governance_type_id], unique: true
    add_index :governance_types, :name, unique: true
  end
end
