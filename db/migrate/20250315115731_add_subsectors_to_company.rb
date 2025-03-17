class AddSubsectorsToCompany < ActiveRecord::Migration[6.1]
  def change
    create_table :company_subsectors, id: false do |t|
      t.references :company, null: false, foreign_key: true
      t.string :subsector, null: false

      t.timestamps
    end
  end
end
