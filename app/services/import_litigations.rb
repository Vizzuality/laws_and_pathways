class ImportLitigations
  include ClimateWatchEngine::CSVImporter

  FILEPATH = "#{FILES_PREFIX}litigation.csv".freeze

  def call
    ActiveRecord::Base.transaction do
      import
    end
  end

  private

  def import
    import_each_with_logging(csv, FILEPATH) do |row|
      l = Litigation.find_or_initialize_by(title: row[:title])
      l.update!(litigation_attributes(row))
    end
  end

  def csv
    @csv ||= S3CSVReader.read(FILEPATH)
  end

  def litigation_attributes(row)
    {
      title: row[:title],
      document_type: row[:document_type],
      location: Location.find_by!(iso: row[:country_iso]),
      citation_reference_number: row[:citation_reference_number],
      core_objective: row[:core_objective],
      summary: row[:description],
      keywords: row[:keywords]
    }
  end
end
