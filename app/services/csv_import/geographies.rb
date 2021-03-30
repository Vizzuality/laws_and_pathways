module CSVImport
  class Geographies < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        geography = prepare_geography(row)

        geography.political_groups = parse_tags(row[:political_groups], political_groups) if row.header?(:political_groups)

        geography.name = row[:name] if row.header?(:name)
        geography.region = row[:world_bank_region] if row.header?(:world_bank_region)
        geography.iso = row[:iso] if row.header?(:iso)
        geography.federal = row[:federal] if row.header?(:federal)
        geography.federal_details = row[:federal_details] if row.header?(:federal_details)
        geography.legislative_process = row[:legislative_process] if row.header?(:legislative_process)
        geography.geography_type = row[:geography_type].downcase if row.header?(:geography_type)
        geography.percent_global_emissions = row[:percent_global_emissions] if row.header?(:percent_global_emissions)
        geography.climate_risk_index = row[:climate_risk_index] if row.header?(:climate_risk_index)
        geography.wb_income_group = row[:wb_income_group] if row.header?(:wb_income_group)
        geography.visibility_status = row[:visibility_status] if row.header?(:visibility_status)

        was_new_record = geography.new_record?
        any_changes = geography.changed?

        geography.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Geography
    end

    def required_headers
      [:id]
    end

    def prepare_geography(row)
      find_record_by(:id, row) ||
        find_record_by(:iso, row) ||
        resource_klass.new
    end
  end
end
