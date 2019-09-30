class AddDiscardedAtToGovernanceType < ActiveRecord::Migration[5.2]
  def change
    add_column :governance_types, :discarded_at, :datetime
    add_index :governance_types, :discarded_at
  end
end
