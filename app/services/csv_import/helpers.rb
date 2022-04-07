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

    def parse_cp_benchmark_region(region)
      cp_benchmarks_regions_hash[region&.downcase]
    end

    def cp_benchmarks_regions_hash
      @cp_benchmarks_regions_hash ||= CP::Benchmark::REGIONS.map { |r| {r.downcase => r} }.reduce(&:merge)
    end

    def find_geography(row_value)
      geographies[row_value&.upcase]
    end

    def find_or_create_tpi_sectors(row_sectors)
      return [] unless row_sectors.present?

      row_sectors
        .split(Rails.application.config.csv_options[:entity_sep])
        .map { |sector_name| find_or_create_tpi_sector(sector_name) }
        .uniq
    end

    def find_or_create_tpi_sector(sector_name)
      return unless sector_name.present?

      TPISector.where('lower(name) = ?', sector_name.downcase).first ||
        TPISector.new(name: sector_name)
    end

    def find_or_create_laws_sectors(row_sectors)
      return [] unless row_sectors.present?

      row_sectors
        .split(Rails.application.config.csv_options[:entity_sep])
        .map { |sector_name| find_or_create_laws_sector(sector_name) }
        .uniq
    end

    def find_or_create_laws_sector(sector_name)
      return nil unless sector_name.present?

      sector_name = sector_name.strip
      LawsSector.where('lower(name) = ?', sector_name.downcase).first ||
        LawsSector.new(name: sector_name.titleize)
    end

    def missing_header(header)
      CSVImport::MissingHeader.new("CSV missing header: #{header}")
    end
  end
end
