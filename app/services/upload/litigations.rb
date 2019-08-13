module Upload
  class Litigations < BaseUploader
    include UploaderHelpers

    def import
      import_each_with_logging(csv) do |row|
        litigation = find_litigation(row[:id]) || Litigation.new
        litigation.keywords = parse_tags(row[:keywords], keywords)
        litigation.assign_attributes(litigation_attributes(row))

        was_new_record = litigation.new_record?
        any_changes = litigation.changed?

        litigation.save!

        update_stats(was_new_record, any_changes)
      end
    end

    private

    def find_litigation(id)
      Litigation.find(id) if id.present?
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
