class CreateJoinTableLitigationExternalLegislation < ActiveRecord::Migration[5.2]
  def change
    create_join_table :litigations, :external_legislations do |t|
      t.index :litigation_id
      t.index :external_legislation_id, name: 'index_external_legislations_litigations', unique: true
    end
  end
end
