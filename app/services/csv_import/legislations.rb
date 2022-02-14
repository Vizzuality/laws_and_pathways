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

        legislation.title = row[:title] if row.header?(:title)
        legislation.legislation_type = row[:legislation_type]&.downcase if row.header?(:legislation_type)
        legislation.description = row[:description].presence if row.header?(:description)
        legislation.parent_id = row[:parent_id] if row.header?(:parent_id)
        legislation.geography = find_geography(row[:geography_iso]) if row.header?(:geography_iso)
        legislation.laws_sectors = find_or_create_laws_sectors(row[:sectors]) if row.header?(:sectors)
        legislation.frameworks = parse_tags(row[:frameworks], frameworks) if row.header?(:frameworks)
        legislation.responses = parse_tags(row[:responses], responses) if row.header?(:responses)
        legislation.keywords = parse_tags(row[:keywords], keywords) if row.header?(:keywords)
        legislation.natural_hazards = parse_tags(row[:natural_hazards], natural_hazards) if row.header?(:natural_hazards)
        legislation.document_types = parse_tags(row[:document_types], document_types) if row.header?(:document_types)
        legislation.instruments = find_instruments(row[:instruments]) if row.header?(:instruments)
        legislation.governances = find_governances(row[:governances]) if row.header?(:governances)
        legislation.litigation_ids = parse_ids(row[:litigation_ids]) if row.header?(:litigation_ids)
        legislation.visibility_status = row[:visibility_status]&.downcase if row.header?(:visibility_status)

        was_new_record = legislation.new_record?
        any_changes = legislation.changed?

        legislation.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      Legislation
    end

    def required_headers
      [:id]
    end

    def prepare_legislation(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) ||
        find_record_by(:title, row) ||
        resource_klass.new
    end

    def find_governances(str)
      return [] unless str.present?

      str.split(';').flat_map do |governance_type_string|
        governance_name, type_name = governance_type_string.split('|').map(&:strip)

        raise "Governance #{governance_name} has no type" unless type_name.present?
        raise "No name for governance of type #{type_name}" if type_name.present? && !governance_name.present?

        type = GovernanceType.where('lower(name) = ?', type_name.downcase).first
        raise "Cannot find Governance Type: #{type_name}" unless type.present?

        governance = Governance.where(governance_type_id: type.id).where('lower(name) = ?', governance_name.downcase).first
        raise "Cannot find Governance: '#{governance_name}' of type '#{type.name}'" unless governance.present?

        governance
      end
    end

    def find_instruments(str)
      return [] unless str.present?

      str.split(';').flat_map do |instrument_type_string|
        instrument_name, type_name = instrument_type_string.split('|').map(&:strip)

        raise "Instrument #{instrument_name} has no type" unless type_name.present?
        raise "No name for instrument of type #{type_name}" if type_name.present? && !instrument_name.present?

        type = InstrumentType.where('lower(name) = ?', type_name.downcase).first
        raise "Cannot find Instrument Type: #{type_name}" unless type.present?

        instrument = Instrument.where(instrument_type_id: type.id).where('lower(name) = ?', instrument_name.downcase).first
        raise "Cannot find Instrument: '#{instrument_name}' of type '#{type.name}'" unless instrument.present?

        instrument
      end
    end
  end
end
