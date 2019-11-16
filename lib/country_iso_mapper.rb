module CountryISOMapper
  NOT_FOUND_MAP = {
    'EU' => 'EUR',
    'XK' => 'XKX'
  }.freeze

  def self.alpha2_to_alpha3(alpha2)
    ISO3166::Country.new(alpha2)&.alpha3 || NOT_FOUND_MAP[alpha2.upcase]
  end
end
