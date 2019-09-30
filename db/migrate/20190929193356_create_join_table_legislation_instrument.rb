class CreateJoinTableLegislationInstrument < ActiveRecord::Migration[5.2]
  def change
    create_join_table :legislations, :instruments do |t|
      t.index :legislation_id
      t.index :instrument_id
    end
  end
end
