module CSVImport
  class Industries < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        industry = prepare_industry(row)

        industry.name = row[:name] if row.header?(:name)
        
        was_new_record = industry.new_record?
        any_changes = industry.changed?

        industry.save!

        if row.header?(:sector_names) && row[:sector_names].present?
          sectors = find_tpi_sectors(row[:sector_names])
          industry.tpi_sectors = sectors
        end

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Industry
    end

    def required_headers
      [:name]
    end

    def prepare_industry(row)
      return prepare_overridden_resource(row) if override_id && row.header?(:id)

      (find_record_by(:id, row) if row.header?(:id)) ||
        find_record_by(:name, row) ||
        resource_klass.new
    end

    def find_tpi_sectors(sector_names)
      return [] unless sector_names.present?

      sector_names
        .split(Rails.application.config.csv_options[:entity_sep])
        .map(&:strip)
        .map { |sector_name| tpi_sectors[sector_name.downcase] }
        .compact
    end
  end
end
