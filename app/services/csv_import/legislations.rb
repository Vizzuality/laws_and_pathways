module CSVImport
  class Legislations < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        legislation = find_legislation(row) || Legislation.new
        legislation.frameworks = parse_tags(row[:frameworks], frameworks)
        legislation.document_types = parse_tags(row[:document_types], document_types)

        legislation.assign_attributes(litigation_attributes(row))

        was_new_record = legislation.new_record?
        any_changes = legislation.changed?

        legislation.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def find_legislation(row)
      find_by = ->(name) { Legislation.find_by(name.to_sym => row[name]&.strip) }

      find_by[:id] || find_by[:law_id] || find_by[:title]
    end

    def litigation_attributes(row)
      {
        law_id: row[:law],
        title: row[:title],
        date_passed: row[:date_passed],
        description: row[:description],
        geography: geographies[row[:geography_iso]],
        visibility_status: row[:visibility_status]
      }
    end
  end
end
