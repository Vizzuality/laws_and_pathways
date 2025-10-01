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
  end
end
