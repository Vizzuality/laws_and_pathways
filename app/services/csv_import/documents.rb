module CSVImport
  # only for development purporses, only external documents
  class Documents < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        if override_id && Document.where(id: row[:id]).any?
          puts "skipping #{row[:id]}"
          next
        end
        document = prepare_document(row)
        document.assign_attributes(document_attributes(row))

        was_new_record = document.new_record?
        any_changes = document.changed?

        document.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Document
    end

    def prepare_document(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) ||
        resource_klass.new
    end

    def document_attributes(row)
      {
        name: row[:name],
        type: 'external',
        language: row[:language],
        external_url: row[:external_url],
        last_verified_on: row[:last_verified_on],
        documentable_id: row[:documentable_id].to_i,
        documentable_type: row[:documentable_type].constantize
      }
    end
  end
end
