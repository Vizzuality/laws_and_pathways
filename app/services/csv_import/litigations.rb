module CSVImport
  class Litigations < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        if override_id && Litigation.where(id: row[:id]).any?
          puts "skipping #{row[:id]}"
          next
        end
        litigation = prepare_litigation(row)

        litigation.title = row[:title] if row.header?(:title)
        litigation.document_type = row[:document_type]&.parameterize&.underscore if row.header?(:document_type)
        litigation.geography = geographies[row[:geography_iso]&.upcase] if row.header?(:geography_iso)
        litigation.jurisdiction = row[:jurisdiction] if row.header?(:jurisdiction)
        litigation.citation_reference_number = row[:citation_reference_number] if row.header?(:citation_reference_number)
        litigation.at_issue = row[:at_issue] if row.header?(:at_issue)
        litigation.summary = row[:summary] if row.header?(:summary)
        litigation.visibility_status = row[:visibility_status]&.downcase if row.header?(:visibility_status)
        litigation.legislation_ids = parse_ids(row[:legislation_ids]) if row.header?(:legislation_ids)

        litigation.responses = parse_tags(row[:responses], responses) if row.header?(:responses)
        litigation.keywords = parse_tags(row[:keywords], keywords) if row.header?(:keywords)
        # TODO: decide if only one separator or many possible
        litigation.laws_sectors = find_or_create_laws_sectors(row[:sectors]&.split(/,|;/)) if row.header?(:sectors)

        was_new_record = litigation.new_record?
        any_changes = litigation.changed?

        litigation.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Litigation
    end

    def required_headers
      [:id]
    end

    # to avoid doubling records when uploading the same record without id (new record)
    # if there is nothing in id column try to find Litigation by title first before
    # creating new record
    def prepare_litigation(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) || find_record_by(:title, row) || resource_klass.new
    end
  end
end
