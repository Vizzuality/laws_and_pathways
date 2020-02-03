class CreateCPUnits < ActiveRecord::Migration[6.0]
  TPISector = Class.new(ActiveRecord::Base)
  class CPUnit < ActiveRecord::Base
    belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'
  end

  def up
    create_table :cp_units do |t|
      t.references :sector, foreign_key: {to_table: :tpi_sectors, on_delete: :cascade}, index: true
      t.date :valid_since
      t.text :unit, null: false

      t.timestamps
    end

    TPISector.find_each do |sector|
      next unless sector.cp_unit.present?

      CPUnit.create!(sector: sector, unit: sector.cp_unit)
    end

    remove_column :tpi_sectors, :cp_unit
  end

  def down
    add_column :tpi_sectors, :cp_unit, :text

    CPUnit
      .all
      .group_by(&:sector_id).map { |_grouping, units| units.max(&:valid_since) }
      .each { |cp_unit| cp_unit.sector.update!(cp_unit: cp_unit.unit) }

    drop_table :cp_units
  end
end
