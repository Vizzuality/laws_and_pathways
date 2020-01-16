module CSVImport
  class LitigationSides < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        litigation_side = prepare_litigation_side(row)
        litigation_side.assign_attributes(litigation_side_attributes(row))

        was_new_record = litigation_side.new_record?
        any_changes = litigation_side.changed?

        litigation_side.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      LitigationSide
    end

    def prepare_litigation_side(row)
      find_record_by(:id, row) || resource_klass.new
    end

    def litigation_side_attributes(row)
      {
        name: row[:name],
        litigation: Litigation.find(row[:litigation_id]),
        connected_entity_id: row[:connected_entity_id],
        connected_entity_type: row[:connected_entity_type],
        party_type: row[:party_type]&.downcase,
        side_type: row[:side_type]&.downcase
      }
    end
  end
end
