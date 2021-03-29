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

        legislation.litigation_ids = parse_ids(row[:litigation_ids]) if row.header?(:litigation_ids)
        legislation.name = row[:name] if row.header?(:name)
        legislation.url = row[:url] if row.header?(:url)
        legislation.geography = geographies[row[:geography_iso]] if row.header?(:geography_iso)

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
  end
end
