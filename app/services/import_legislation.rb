class ImportLegislation
  include ClimateWatchEngine::CSVImporter

  FILEPATH = "#{FILES_PREFIX}legislation.csv".freeze

  FRAMEWORK_MAPPING = {
    'No' => 'no',
    'Mitigation' => 'mitigation',
    'Adaptation' => 'adaptation',
    'Mitigation and adaptation' => 'mitigation_and_adaptation'
  }.freeze

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
      parsed_date = legislation_attributes(row)[:date_passed]
      printf "%-120s %-10s %s\n", row[:date_passed], row[:year_passed], parsed_date
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
      date_passed: find_date_passed(row),
      framework: map_framework(row),
      document_types: find_document_types(row),
      location: find_location(row)
    }
  end

  def find_date_passed(row)
    normalize_date(row[:date_passed]) || normalize_date(row[:year_passed])
  end

  def normalize_date(date)
    return if date.nil?

    sanitized_date = date
      .gsub(/;.*/, '')
      .gsub(/, last amended.*/, '')
      .gsub(/; last amendment.*/, '')
      .gsub(/, amended.*/, '')
      .gsub(/; repealed/, '')
      .gsub(/(.*amended|passed|enacted|approved)[\w\s]*\s/i, '') # [\w\s]*

    try_to_parse_date(sanitized_date) || nil
  end

  def try_to_parse_date(date)
    expected_date_formats = [
      '%d-%b-%y',  # 15-May-97
      '%d %B %Y',  # 15 May 1997
      '%Y',        # 1997
      '%b-%y',     # May-15
      '%b %d, %Y', # May 15, 1997
      '%B %Y'      # November 1997
    ]

    expected_date_formats.map { |format| parse_date(date, format) }.compact.first
  end

  def parse_date(date, format)
    Date.strptime(date, format)
  rescue ArgumentError
    nil
  end

  def find_document_types(row)
    row[:document_types]
      &.gsub(/\s\(.*/, '')
      &.split(/[,;]/)
      &.map(&:strip)
      &.map { |name| {'Radmap' => 'Roadmap'}[name] || name }
      &.map { |name| DocumentType.find_or_create_by!(name: name) }
  end

  def find_location(row)
    Location.find_by!(iso: row[:country_iso])
  rescue StandardError
    puts "Couldn't find Location with ISO: #{row[:country_iso]}"
  end

  def map_framework(row)
    FRAMEWORK_MAPPING[row[:framework_legislation]] || 'no'
  end
end
