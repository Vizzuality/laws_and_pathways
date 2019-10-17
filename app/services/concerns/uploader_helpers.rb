module UploaderHelpers
  EMISSION_YEAR_PATTERN = /\d{4}/.freeze

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

  def frameworks
    @frameworks ||= Hash.new do |hash, keyword|
      hash[keyword] = Framework.find_or_initialize_by(name: keyword)
    end
  end

  def document_types
    @document_types ||= Hash.new do |hash, keyword|
      hash[keyword] = DocumentType.find_or_initialize_by(name: keyword)
    end
  end

  def natural_hazards
    @natural_hazards ||= Hash.new do |hash, keyword|
      hash[keyword] = NaturalHazard.find_or_initialize_by(name: keyword)
    end
  end

  def political_groups
    @political_groups ||= Hash.new do |hash, keyword|
      hash[keyword] = PoliticalGroup.find_or_initialize_by(name: keyword)
    end
  end

  def parse_tags(row_tags, tag_collection)
    return [] if row_tags.nil?

    row_tags
      .split(',')
      .map(&:strip)
      .map { |tag| tag_collection[tag] }
  end

  def parse_emissions(row)
    row.headers.grep(EMISSION_YEAR_PATTERN).reduce({}) do |acc, year|
      next acc unless row[year].present?

      acc.merge(year.to_s.to_i => row[year].to_f)
    end
  end
end
