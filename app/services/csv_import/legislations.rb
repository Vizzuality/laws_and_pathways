module CSVImport
  class Legislations < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        if override_id && Legislation.where(id: row[:id]).any?
          puts "skipping #{row[:id]}"
          next
        end
        legislation = prepare_legislation(row)
        legislation.parent_id = row[:parent_id] if row.header?(:parent_id)
        legislation.frameworks = parse_tags(row[:frameworks], frameworks) if row.header?(:frameworks)
        legislation.document_types = parse_tags(row[:document_types], document_types) if row.header?(:document_types)
        legislation.keywords = parse_tags(row[:keywords], keywords) if row.header?(:keywords)
        legislation.natural_hazards = parse_tags(row[:natural_hazards], natural_hazards) if row.header?(:natural_hazards)
        legislation.responses = parse_tags(row[:responses], responses) if row.header?(:responses)
        legislation.instruments = find_or_create_instruments(row[:instruments]) if row.header?(:instruments)
        legislation.assign_attributes(legislation_attributes(row))

        was_new_record = legislation.new_record?
        any_changes = legislation.changed?

        legislation.save!
        legislation.laws_sectors = find_or_create_laws_sectors(row[:sectors].split(/,|;/)) if row[:sectors]

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
        find_record_by(:title, row) ||
        resource_klass.new
    end

    def legislation_attributes(row)
      {
        title: row[:title],
        description: row[:description],
        geography: geographies[row[:geography_iso]],
        legislation_type: row[:legislation_type]&.downcase,
        visibility_status: row[:visibility_status],
        litigation_ids: parse_ids(row[:connected_litigation_ids])
      }
    end

    def find_or_create_instruments(str)
      return [] unless str.present?

      str.split(';').flat_map do |instrument_type_string|
        instrument, type = instrument_type_string.split('|')

        type = InstrumentType.where('lower(name) = ?', type.downcase).first ||
          InstrumentType.create!(name: type)
        Instrument.where(instrument_type_id: type.id).where('lower(name) = ?', instrument.downcase).first ||
          Instrument.create!(name: instrument, instrument_type: type)
      end
    end
  end
end
