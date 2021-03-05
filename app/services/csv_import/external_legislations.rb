module CSVImport
  # only for development purporses
  class ExternalLegislations < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        if override_id && ExternalLegislation.where(id: row[:id]).any?
          puts "skipping #{row[:id]}"
          next
        end
        legislation = prepare_legislation(row)
        legislation.assign_attributes(legislation_attributes(row))

        was_new_record = legislation.new_record?
        any_changes = legislation.changed?

        legislation.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      ExternalLegislation
    end

    def prepare_legislation(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) ||
        resource_klass.new
    end

    def legislation_attributes(row)
      {
        litigation_ids: parse_ids(row[:litigation_ids]),
        name: row[:name],
        url: row[:url],
        geography: geographies[row[:geography_iso]]
      }
    end
  end
end
