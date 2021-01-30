module UploaderHelpers
  EMISSION_YEAR_PATTERN = /\d{4}/.freeze

  def geographies
    @geographies ||= Hash.new do |hash, iso|
      hash[iso] = Geography.find_by(iso: iso)
    end
  end

  def geographies_names
    @geographies_names ||= Hash.new do |hash, name|
      hash[name] = Geography.find_by(name: name)
    end
  end

  def keywords
    @keywords ||= Hash.new do |hash, keyword|
      hash[keyword.titleize] = Keyword.find_or_initialize_by(name: keyword.titleize)
    end
  end

  def frameworks
    @frameworks ||= Hash.new do |hash, keyword|
      hash[keyword.titleize] = Framework.find_or_initialize_by(name: keyword.titleize)
    end
  end

  def scopes
    @scopes ||= Hash.new do |hash, keyword|
      hash[keyword.titleize] = Scope.find_or_initialize_by(name: keyword.titleize)
    end
  end

  def document_types
    @document_types ||= Hash.new do |hash, keyword|
      hash[keyword.titleize] = DocumentType.find_or_initialize_by(name: keyword.titleize)
    end
  end

  def natural_hazards
    @natural_hazards ||= Hash.new do |hash, keyword|
      hash[keyword.titleize] = NaturalHazard.find_or_initialize_by(name: keyword.titleize)
    end
  end

  def political_groups
    @political_groups ||= Hash.new do |hash, keyword|
      hash[keyword] = PoliticalGroup.find_or_initialize_by(name: keyword)
    end
  end

  def responses
    @responses ||= Hash.new do |hash, keyword|
      hash[keyword.titleize] = Response.find_or_initialize_by(name: keyword.titleize)
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

  def find_or_create_tpi_sector(sector_name)
    return unless sector_name.present?

    TPISector.where('lower(name) = ?', sector_name.downcase).first ||
      TPISector.new(name: sector_name)
  end

  def find_or_create_laws_sectors(sector_names)
    return [] unless sector_names

    sectors = []
    sector_names.each do |sector_name|
      sectors << find_or_create_laws_sector(sector_name)
    end
    sectors.uniq
  end

  def find_or_create_laws_sector(sector_name)
    return nil unless sector_name.present?

    sector_name = sector_name.strip
    LawsSector.where('lower(name) = ?', sector_name.downcase).first ||
      LawsSector.new(name: sector_name.titleize)
  end
end
