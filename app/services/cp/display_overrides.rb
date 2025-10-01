module CP
  class DisplayOverrides
    def self.emissions_only_allowed?(bank_name:, sector_name:)
      rules = load_rules['emissions_only_allow'] || []
      bank = (bank_name || '').to_s.downcase
      sector = (sector_name || '').to_s.downcase

      rules.any? do |rule|
        bank_match = rule['bank']&.to_s&.downcase
        sector_match = rule['sector']&.to_s&.downcase
        (bank_match.nil? || bank.include?(bank_match)) && (sector_match.nil? || sector.include?(sector_match))
      end
    end

    def self.load_rules
      @rules ||= begin
        path = Rails.root.join('config', 'cp_display_overrides.yml')
        File.exist?(path) ? YAML.load_file(path) || {} : {}
      end
    end

    def self.suppressed_sector_names
      Array(load_rules['suppress_sector_names']).map { |s| s.to_s.downcase }
    end

    def self.filter_sectors(sectors)
      suppressed = suppressed_sector_names
      return sectors if suppressed.empty?

      sectors.reject { |sector| suppressed.include?(sector.name.to_s.downcase) }
    end
  end
end
