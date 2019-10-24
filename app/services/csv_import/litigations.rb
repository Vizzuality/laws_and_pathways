module CSVImport
  class Litigations < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        litigation = prepare_litigation(row)
        litigation.keywords = parse_tags(row[:keywords], keywords)
        litigation.assign_attributes(litigation_attributes(row))

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
        document_type: row[:document_type]&.downcase,
        geography: geographies[row[:geography_iso]],
        jurisdiction: geographies[row[:jurisdiction_iso]],
        sector: find_or_create_laws_sector(row[:sector]),
        citation_reference_number: row[:citation_reference_number],
        core_objective: row[:core_objective],
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
