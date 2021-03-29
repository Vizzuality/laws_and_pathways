module CSVImport
  class LitigationSides < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        litigation_side = prepare_litigation_side(row)

        litigation_side.name = row[:name] if row.header?(:name)
        litigation_side.litigation = Litigation.find(row[:litigation_id]) if row.header?(:litigation_id)
        litigation_side.connected_entity_id = row[:connected_entity_id] if row.header?(:connected_entity_id)
        litigation_side.connected_entity_type = row[:connected_entity_type] if row.header?(:connected_entity_type)
        litigation_side.party_type = row[:party_type]&.downcase if row.header?(:party_type)
        litigation_side.side_type = row[:side_type]&.downcase if row.header?(:side_type)

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
  end
end
