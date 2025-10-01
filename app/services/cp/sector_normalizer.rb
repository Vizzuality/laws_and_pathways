module CP
  class SectorNormalizer
    def self.config
      @config ||= begin
        path = Rails.root.join('config', 'sector_aliases.yml')
        File.exist?(path) ? YAML.load_file(path) || {} : {}
      end
    end

    def self.normalize(sector_name, subsector_name = nil)
      return [nil, nil] unless sector_name.present?

      aliases = config['aliases'] || {}
      allowlist = config['allowlist'] || {}

      sect_key = sector_name.to_s.strip
      sub_key = subsector_name.to_s.strip.presence

      # Resolve alias to canonical sector/subsector
      if aliases[sect_key]
        aliased = aliases[sect_key]
        sect_key = aliased['sector'] || sect_key
        sub_key = aliased['subsector'] || sub_key
      end

      # Validate against allowlist when available
      if allowlist[sect_key]
        allowed_subs = Array(allowlist[sect_key])
        if sub_key.present? && !allowed_subs.include?(sub_key)
          raise ArgumentError, "Unknown subsector '#{sub_key}' for sector '#{sect_key}'"
        end
      end

      [sect_key, sub_key]
    end
  end
end
