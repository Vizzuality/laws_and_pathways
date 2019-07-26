class ImportLitigations
  include ClimateWatchEngine::CSVImporter

  FILEPATH = "#{FILES_PREFIX}litigation.csv".freeze

  def call
    ActiveRecord::Base.transaction do
      cleanup
      import
    end
  end

  private

  def import
    import_each_with_logging(csv, FILEPATH) do |row|
      litigation = Litigation.find_or_initialize_by(title: row[:title])
      litigation.update!(litigation_attributes(row))
      get_litigation_sides(row).each do |side|
        side.update!(litigation_id: litigation.id)
      end
    end
  end

  def cleanup
    LitigationSide.delete_all
  end

  def csv
    @csv ||= S3CSVReader.read(FILEPATH)
  end

  def litigation_attributes(row)
    {
      title: row[:title],
      document_type: row[:document_type],
      location: find_location(row[:country_iso]),
      # TODO: change below when we know more about jurisdictions
      jurisdiction: Location.find_by!(iso: row[:country_iso]),
      citation_reference_number: row[:citation_reference_number],
      core_objective: row[:core_objective],
      summary: row[:description],
      keywords: row[:keywords]
    }
  end

  def get_litigation_sides(row)
    sides = []

    sides << get_sides(row[:side_a], row[:side_a_type], 'a')
    sides << get_sides(row[:side_b], row[:side_b_type], 'b')
    sides << get_sides(row[:side_c], row[:side_c_type], 'c')

    sides.flatten.compact
  end

  def get_sides(sides_string, party_types_string, side_type)
    return if sides_string.blank?

    party_types = party_types_string
                    &.split(',')
                    &.map(&:strip)
                    &.map(&:underscore)
                    &.map { |type| type == 'n/a' ? nil : type } || []

    sides_string.split(',').map.with_index do |side, index|
      LitigationSide.new(
        name: side,
        side_type: side_type,
        party_type: party_types[index],
        connected_entity: get_side_connected_entity(side)
      )
    end
  end

  def get_side_connected_entity(name)
    location = Location.find_by(name: name)
    return location if location.present?

    Company.find_by(name: name)
  end

  def find_location(iso)
    Location.find_by!(iso: iso)
  rescue StandardError
    puts "Couldn't find Location with ISO: #{iso}"
  end
end
