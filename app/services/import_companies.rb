class ImportCompanies
  include ClimateWatchEngine::CSVImporter

  FILEPATH = "#{FILES_PREFIX}companydata.csv".freeze

  def call
    ActiveRecord::Base.transaction do
      import
    end
  end

  private

  def import
    import_each_with_logging(csv, FILEPATH) do |row|
      company = Company.find_or_initialize_by(isin: row[:isin])
      company.update!(company_attributes(row))
    end
  end

  def csv
    @csv ||= S3CSVReader.read(FILEPATH)
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
