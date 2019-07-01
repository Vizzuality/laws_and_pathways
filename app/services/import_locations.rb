class ImportLocations
  include ClimateWatchEngine::CSVImporter

  FILEPATH = "#{FILES_PREFIX}countryprofiles.csv".freeze

  def call
    ActiveRecord::Base.transaction do
      import
    end
  end

  private

  def import
    import_each_with_logging(csv, FILEPATH) do |row|
      location = Location.find_or_initialize_by(iso: row[:country_iso])
      location.update!(location_attributes(row))
    end
  end

  def csv
    @csv ||= S3CSVReader.read(FILEPATH)
  end

  def location_attributes(row)
    {
      name: row[:country],
      region: row[:region],
      iso: row[:country_iso],
      federal: parse_boolean(row[:federal]),
      federal_details: row[:federal_details],
      location_type: 'country'
    }
  end

  def parse_boolean(value)
    value.to_s == '1'
  end
end
