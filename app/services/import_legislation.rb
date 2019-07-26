class ImportLegislation
  include ClimateWatchEngine::CSVImporter
  include ImportHelpers

  FILEPATH = "#{FILES_PREFIX}legislation.csv".freeze

  FRAMEWORK_MAPPING = {
    'No' => 'no',
    'Mitigation' => 'mitigation',
    'Adaptation' => 'adaptation',
    'Mitigation and adaptation' => 'mitigation_and_adaptation'
  }.freeze

  DOCUMENT_TYPE_MAPPING = {
    'Radmap' => 'Roadmap'
  }.freeze

  DATE_PASSED_VALID_FORMATS = [
    '%d-%b-%y',  # 15-May-97
    '%d-%b-%Y',  # 15-May-1997
    '%d %B %Y',  # 15 May 1997
    '%d/%m/%Y',  # 04/08/2014
    '%B %d, %Y', # May 15, 1997
    '%b-%y',     # May-15
    '%B %Y',     # November 1997
    '%Y' # 1997
  ].freeze

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
      date_passed: find_date_passed(row),
      document_types: find_document_types(row),
      location: find_location(row[:country_iso])
    }
  end

  def find_date_passed(row)
    normalize_date(row[:date_passed]) || normalize_date(row[:year_passed])
  end

  def normalize_date(date)
    return if date.nil?

    sanitized_date = date
      .gsub(/([;]+(\s).*)|\s\(.*\)|(,\s.*(last|latest|amend|regulated).*)/, '')
      .gsub(/(.*amended|passed|enacted|approved)[\w\s]*\s/i, '')

    try_to_parse_date(sanitized_date, DATE_PASSED_VALID_FORMATS) || nil
  end

  def find_document_types(row)
    row[:document_types]
      &.gsub(/\s\(.*/, '')
      &.split(/[,;]/)
      &.map(&:strip)
      &.map { |name| DOCUMENT_TYPE_MAPPING[name] || name }
      &.map { |name| DocumentType.find_or_create_by!(name: name) }
  end

  def map_framework(row)
    FRAMEWORK_MAPPING[row[:framework_legislation]] || 'no'
  end
end
