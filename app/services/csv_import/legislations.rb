module CSVImport
  class Legislations < BaseImporter
    include UploaderHelpers
    def import
      import_each_csv_row(csv) do |row|
        if override_id && Legislation.where(id: row[:id]).any?
          puts "skipping #{row[:id]}"
          next
        end
        legislation = prepare_legislation(row)
        legislation.frameworks = parse_tags(row[:frameworks], frameworks)
        legislation.document_types = parse_tags(row[:document_types], document_types)
        legislation.keywords = parse_tags(row[:keywords], keywords)
        legislation.natural_hazards = parse_tags(row[:natural_hazards], natural_hazards)
        legislation.responses = parse_tags(row[:responses], responses)

        legislation.assign_attributes(legislation_attributes(row))

        was_new_record = legislation.new_record?
        any_changes = legislation.changed?

        legislation.save!
        legislation.laws_sectors = find_or_create_laws_sectors(row[:sector].split(',')) if row[:sector]

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Legislation
    end

    def prepare_legislation(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) ||
        find_record_by(:law_id, row) ||
        find_record_by(:title, row) ||
        resource_klass.new
    end

    def legislation_attributes(row)
      {
        law_id: row[:law_id],
        title: row[:title],
        description: row[:description],
        geography: geographies[row[:geography_iso]],
        legislation_type: row[:legislation_type]&.downcase,
        visibility_status: row[:visibility_status]
      }
    end
  end
end
