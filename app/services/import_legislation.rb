class ImportLegislation
  include ClimateWatchEngine::CSVImporter

  FILEPATH = "#{FILES_PREFIX}legislation.csv".freeze

  def call
    ActiveRecord::Base.transaction do
      cleanup
      import
    end
  end

  private

  def import
    import_each_with_logging(csv, FILEPATH) do |row|
      legislation = Legislation.find_or_initialize_by(law_id: row[:law_id])
      legislation.update!(legislation_attributes(row))
    end
  end

  def csv
    @csv ||= S3CSVReader.read(FILEPATH)
  end

  def cleanup
    Legislation.delete_all
  end

  def legislation_attributes(row)
    {
      title: row[:title],
      description: row[:description],
      framework: map_framework(row),
      location: find_location(row)
    }
  end

  def find_location(row)
    Location.find_by!(iso: row[:country_iso])
  rescue StandardError
    puts "Couldn't find Location with ISO: #{row[:country_iso]}"
  end

  def map_framework(row)
    {
      'No' => 'no',
      'Mitigation' => 'mitigation',
      'Adaptation' => 'adaptation',
      'Mitigation and adaptation' => 'mitigation_and_adaptation'
    }[row[:framework_legislation]] || 'no'
  end
end
