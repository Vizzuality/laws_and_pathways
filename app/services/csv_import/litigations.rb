module CSVImport
  class Litigations < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        if override_id && Litigation.where(id: row[:id]).any?
          puts "skipping #{row[:id]}"
          next
        end
        litigation = prepare_litigation(row)
        litigation.assign_attributes(litigation_attributes(row))

        was_new_record = litigation.new_record?
        any_changes = litigation.changed?

        litigation.save!
        litigation.responses = parse_tags(row[:responses], responses)
        litigation.keywords = parse_tags(row[:keywords], keywords)
        litigation.laws_sectors = find_or_create_laws_sectors(row[:sector]&.split(','))

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Litigation
    end

    # to avoid doubling records when uploading the same record without id (new record)
    # if there is nothing in id column try to find Litigation by title first before
    # creating new record
    def prepare_litigation(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) || find_record_by(:title, row) || resource_klass.new
    end

    def litigation_attributes(row)
      {
        title: row[:title],
        document_type: row[:document_type]&.parameterize&.underscore,
        geography: geographies[row[:geography_iso]&.upcase],
        jurisdiction: row[:jurisdiction],
        citation_reference_number: row[:citation_reference_number],
        at_issue: row[:at_issue],
        summary: row[:summary],
        visibility_status: row[:visibility_status]&.downcase,
        legislation_ids: legislation_ids(row)
      }
    end

    def legislation_ids(row)
      return [] unless row[:legislation_ids].present?

      row[:legislation_ids].split(',').map(&:to_i)
    end
  end
end
