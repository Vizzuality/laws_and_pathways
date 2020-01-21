module CSVImport
  class Geographies < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        # check_permissions_for_row(row)

        geography = prepare_geography(row)
        geography.political_groups = parse_tags(row[:political_groups], political_groups)

        geography.assign_attributes(geography_attributes(row))

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

    def prepare_geography(row)
      find_record_by(:id, row) ||
        find_record_by(:iso, row) ||
        resource_klass.new
    end

    def geography_attributes(row)
      {
        name: row[:name],
        region: row[:world_bank_region],
        iso: row[:iso],
        federal: row[:federal],
        federal_details: row[:federal_details],
        legislative_process: row[:legislative_process],
        geography_type: row[:geography_type].downcase,
        visibility_status: row[:visibility_status]
      }
    end
  end
end
