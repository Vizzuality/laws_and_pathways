module Import
  class Legislation
    include ClimateWatchEngine::CSVImporter

    FILEPATH = "#{FILES_PREFIX}legislation.csv".freeze

    FRAMEWORK_MAPPING = {
      'No' => nil,
      'Mitigation' => 'Mitigation',
      'Adaptation' => 'Adaptation',
      'Adaptiona' => 'Adaptation',
      'Mitigation and adaptation' => %w(Mitigation Adaptation)
    }.freeze

    DOCUMENT_TYPE_MAPPING = {
      'Radmap' => 'Roadmap'
    }.freeze

    DATE_PASSED_VALID_FORMATS = [
      '%d-%b-%Y',  # 15-May-1997
      '%d %B %Y',  # 15 May 1997
      '%d/%m/%Y',  # 04/08/2014
      '%B %d, %Y', # May 15, 1997
      '%d-%b-%y',  # 15-May-97
      '%b-%Y',     # jun-2009
      '%b-%y',     # May-15
      '%B %Y',     # November 1997
      '%Y'         # 1997
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
        legislation = ::Legislation.find_or_initialize_by(law_id: row[:law_id])
        legislation.frameworks_list = map_framework(row)
        legislation.update!(legislation_attributes(row))
      end
    end

    def csv
      @csv ||= S3CSVReader.read(FILEPATH)
    end

    def cleanup
      ::Framework.delete_all
      ::Legislation.delete_all
      ::Document.from_documentable('Litigation').delete_all
    end

    def legislation_attributes(row)
      {
        title: row[:title],
        description: row[:description],
        date_passed: find_date_passed(row),
        document_types: find_document_types(row),
        geography: Import::GeographyUtils.find_by_iso(row[:country_iso]),
        legislation_type: row[:executive_legislative].downcase,
        documents: create_documents(row)
      }
    end

    def find_date_passed(row)
      normalize_date(row[:date_passed]) || normalize_date(row[:year_passed])
    end

    def create_documents(row)
      url_data_list = row[:source_text_links].split(',')

      url_data_list.map do |url_data|
        # expected
        # - law_document_url  # => '//www.lse.ac.uk/GranthamInstitute/wp-content/uploads/laws/1006.pdf'
        # - verification_date # => '(01/02/2018)'
        law_document_url, verification_date = url_data.split
        # - document_filename # => 1006.pdf
        document_filename = law_document_url.split('/').last

        Document.create(
          name: "#{document_filename} (imported)",
          external_url: law_document_url,
          type: 'external',
          last_verified_on: Date.parse(verification_date)
        )
      end
    end

    def normalize_date(date)
      return if date.nil?

      sanitized_date = date
        .gsub(/([;]+(\s).*)|\s\(.*\)|(,\s.*(last|latest|amend|regulated).*)/, '')
        .gsub(/(.*amended|passed|enacted|approved)[\w\s]*\s/i, '')

      Import::DateUtils.safe_parse(sanitized_date, DATE_PASSED_VALID_FORMATS) || nil
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
      FRAMEWORK_MAPPING[row[:framework_legislation]]
    end
  end
end
