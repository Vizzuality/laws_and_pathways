module CSVImport
  class Legislations < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        legislation = prepare_legislation(row)
        legislation.frameworks = parse_tags(row[:frameworks], frameworks)
        legislation.document_types = parse_tags(row[:document_types], document_types)
        legislation.keywords = parse_tags(row[:keywords], keywords)
        legislation.natural_hazards = parse_tags(row[:natural_hazards], natural_hazards)

        legislation.assign_attributes(legislation_attributes(row))

        was_new_record = legislation.new_record?
        any_changes = legislation.changed?

        legislation.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Legislation
    end

    def prepare_legislation(row)
      find_record_by(:id, row) ||
        find_record_by(:law_id, row) ||
        find_record_by(:title, row) ||
        resource_klass.new
    end

    def legislation_attributes(row)
      {
        law_id: row[:law],
        title: row[:title],
        date_passed: row[:date_passed],
        description: row[:description],
        geography: geographies[row[:geography_iso]],
        legislation_type: row[:legislation_type].downcase,
        visibility_status: row[:visibility_status]
      }
    end
  end
end
