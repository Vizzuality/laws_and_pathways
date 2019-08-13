module UploaderHelpers
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

  def parse_tags(row_tags, tag_collection)
    return [] if row_tags.nil?

    row_tags
      .split(',')
      .map(&:strip)
      .map { |tag| tag_collection[tag] }
  end
end
