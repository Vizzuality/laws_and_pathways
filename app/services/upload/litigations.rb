module Upload
  class Litigations < BaseUploader
    def import
      import_each_with_logging(csv) do |row|
        litigation = find_litigation(row[:id]) || Litigation.new
        litigation.keywords = parse_keywords(row[:keywords])
        litigation.update!(litigation_attributes(row))
      end
    end

    private

    def geographies
      @geographies ||= Hash.new do |hash, iso|
        hash[iso] = Geography.find_by(iso: iso)
      end
    end

    def keywords
      @keywords ||= Hash.new do |hash, keyword|
        hash[keyword] = Keyword.find_or_initialize_by(name: keyword)
      end
    end

    def find_litigation(id)
      Litigation.find(id) if id.present?
    end

    def litigation_attributes(row)
      {
        title: row[:title],
        document_type: row[:document_type]&.downcase,
        geography: geographies[row[:geography_iso]],
        jurisdiction: geographies[row[:jurisdiction_iso]],
        citation_reference_number: row[:citation_reference_number],
        core_objective: row[:core_objective],
        summary: row[:summary]
      }
    end

    def parse_keywords(row_keywords)
      return [] if row_keywords.nil?

      row_keywords
        .split(',')
        .map(&:strip)
        .map { |keyword| keywords[keyword] }
    end
  end
end
