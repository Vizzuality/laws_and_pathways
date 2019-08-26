module CSVImport
  class Litigations < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        litigation = find_litigation(row) || Litigation.new
        litigation.keywords = parse_tags(row[:keywords], keywords)
        litigation.assign_attributes(litigation_attributes(row))

        was_new_record = litigation.new_record?
        any_changes = litigation.changed?

        litigation.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    # to avoid doubling records when uploading the same record without id (new record)
    # if there is nothing in id column try to find Litigation by title first before
    # creating new record
    def find_litigation(row)
      return Litigation.find(row[:id]) if row[:id].present?

      Litigation.find_by(title: row[:title].strip) if row[:title].present?
    end

    def litigation_attributes(row)
      {
        title: row[:title],
        document_type: row[:document_type]&.downcase,
        geography: geographies[row[:geography_iso]],
        jurisdiction: geographies[row[:jurisdiction_iso]],
        citation_reference_number: row[:citation_reference_number],
        core_objective: row[:core_objective],
        summary: row[:summary]
      }
    end
  end
end
