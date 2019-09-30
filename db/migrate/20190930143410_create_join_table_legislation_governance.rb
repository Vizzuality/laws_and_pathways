class CreateJoinTableLegislationGovernance < ActiveRecord::Migration[5.2]
  def change
    create_join_table :legislations, :governances do |t|
      t.index :legislation_id
      t.index :governance_id
    end
  end
end
