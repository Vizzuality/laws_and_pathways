class FixUniqueIndecesForExternalLegislationsAndLitigations < ActiveRecord::Migration[6.0]
  def change
    remove_index :external_legislations_litigations, name: :index_external_legislations_litigations
    remove_index :external_legislations_litigations, name: :index_external_legislations_litigations_on_litigation_id
    add_index :external_legislations_litigations, [:litigation_id, :external_legislation_id], unique: true,
      name: :index_external_legislations_and_litigations_ids
  end
end
