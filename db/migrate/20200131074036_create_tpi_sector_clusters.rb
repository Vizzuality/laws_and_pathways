class CreateTPISectorClusters < ActiveRecord::Migration[6.0]
  def change
    create_table :tpi_sector_clusters do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_reference :tpi_sectors, :cluster, foreign_key: { to_table: :tpi_sector_clusters }, index: true
  end
end
