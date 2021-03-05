module CSVImport
  module Helpers
    include Emissions
    include CachedCollections

    def parse_tags(row_tags, tag_collection)
      return [] if row_tags.nil?

      row_tags
        .split(Rails.application.config.csv_options[:entity_sep])
        .map(&:strip)
        .map { |tag| tag_collection[tag] }
    end

    def parse_ids(row_ids)
      return [] unless row_ids.present?

      row_ids
        .split(Rails.application.config.csv_options[:entity_sep])
        .map(&:to_i)
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
end
