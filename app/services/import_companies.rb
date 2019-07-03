class ImportCompanies
  include ClimateWatchEngine::CSVImporter

  FILEPATH = "#{FILES_PREFIX}companydata.csv".freeze

  def call
    ActiveRecord::Base.transaction do
      cleanup
      import
    end
  end

  private

  def import
    import_each_with_logging(csv, FILEPATH) do |row|
      company = Company.find_or_initialize_by(isin: row[:isin])
      company.update!(company_attributes(row))

      MQ::Assessment.create!(
        mq_assessment_attributes(row).merge(company_id: company.id)
      )
    end
  end

  def cleanup
    MQ::Assessment.destroy_all
  end

  def csv
    @csv ||= S3CSVReader.read(FILEPATH, header_converters: header_converter)
  end

  def header_converter
    lambda do |h|
      return h if h.strip.end_with?('?')

      CSV::HeaderConverters[:symbol].call(h)
    end
  end

  def company_attributes(row)
    location = find_location(row[:country_code])

    {
      name: row[:company_name],
      ca100: row[:ca100_company?] == 'Yes',
      location: location,
      headquarter_location: location,
      sector: Sector.find_or_create_by!(name: row[:sector_code]),
      size: row[:largemedium_classification]&.downcase
    }
  end

  def mq_assessment_attributes(row)
    {
      publication_date: normalize_date(row[:publication_date]),
      assessment_date: normalize_date(row[:management_quality_assessment_date]),
      level: row[:level],
      questions: get_questions(row)
    }
  end

  def get_questions(row)
    question_headers = row.headers.map(&:to_s)
                         .select { |h| h.strip.end_with?('?') }
                         .reject { |h| h.start_with?('CA100') }

    question_headers.map do |q_header|
      answer = row[q_header]

      next if answer.nil?
      next if answer.include?('Not applicable to the methodology')

      {
        question: parse_question(q_header),
        answer: answer
      }
    end.compact
  end

  def normalize_date(date)
    return if date.nil?

    try_to_parse_date(date) || date
  end

  def try_to_parse_date(date)
    expected_formats = ['%m/%d/%Y', '%a-%y']

    expected_formats.map { |format| parse_date(date, format) }.compact.first
  end

  def parse_date(date, format)
    Date.strptime(date, format)
  rescue ArgumentError
    nil
  end

  def parse_question(q)
    return unless q.present?

    q[((q.index('|') || -1) + 1)..-1]
  end

  def parse_boolean(value)
    value.to_s == 'Yes'
  end

  def find_location(iso)
    Location.find_by!(iso: fix_iso(iso))
  rescue
    puts "Coulnd't find Location with ISO: #{iso}"
  end

  # TODO: remove this when they fix the file
  def fix_iso(iso)
    {
      'AT' => 'AUT',
      'AU' => 'AUS',
      'BRAZ' => 'BRA',
      'DEN' => 'DNK',
      'GER' => 'DEU',
      'HK' => 'HKG',
      'IDA' => 'IND',
      'INDO' => 'IDN',
      'JA' => 'JPN',
      'MAL' => 'MYS',
      'MX' => 'MEX',
      'NETH' => 'NLD',
      'NZ' => 'NZL',
      'PHIL' => 'PHL',
      'SAF' => 'ZAF',
      'SI' => 'SVN',
      'SP' => 'ESP',
      'SWED' => 'SWE',
      'SWIT' => 'CHE',
      'THAI' => 'THA',
      'UK' => 'GBR'
    }[iso] || iso
  end
end
