class CreateLitigationsLegislationsJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :litigations, :legislations do |t|
      t.index :litigation_id
      t.index :legislation_id
    end
  end
end
