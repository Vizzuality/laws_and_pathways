class CreateGovernances < ActiveRecord::Migration[5.2]
  def change
    create_table :governances do |t|
      t.string :name
      t.references :governance_type, foreign_key: true

      t.timestamps
    end
  end
end
