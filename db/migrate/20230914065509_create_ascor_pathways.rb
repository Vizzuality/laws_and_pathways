class CreateASCORPathways < ActiveRecord::Migration[6.1]
  def change
    create_table :ascor_pathways do |t|
      t.references :country, null: false, foreign_key: { to_table: :ascor_countries }
      t.string :emissions_metric
      t.string :emissions_boundary
      t.string :land_use
      t.string :units
      t.date :assessment_date
      t.date :publication_date, null: true
      t.integer :last_reported_year, null: true
      t.string :trend_1_year, null: true
      t.string :trend_3_year, null: true
      t.string :trend_5_year, null: true
      t.jsonb :emissions, default: {}

      t.timestamps
    end
  end
end
