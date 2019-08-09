module Import
  class Geographies
    include ClimateWatchEngine::CSVImporter

    FILEPATH = "#{FILES_PREFIX}countryprofiles.csv".freeze

    def call
      ActiveRecord::Base.transaction do
        cleanup
        import
      end
    end

    private

    def cleanup
      PoliticalGroup.destroy_all
    end

    def import
      import_each_with_logging(csv, FILEPATH) do |row|
        geography = Geography.find_or_initialize_by(iso: row[:country_iso])
        geography.update!(geography_attributes(row))
      end
    end

    def csv
      @csv ||= S3CSVReader.read(FILEPATH)
    end

    def geography_attributes(row)
      {
        name: row[:country],
        region: row[:region],
        iso: row[:country_iso],
        federal: parse_boolean(row[:federal]),
        federal_details: strip_html(row[:federal_details]),
        legislative_process: row[:legislative_process],
        geography_type: 'country',
        political_groups: parse_political_groups(row[:main_groups])
      }
    end

    def parse_political_groups(groups)
      return [] unless groups.present?

      groups.split(/[,;]/).map(&:strip).map do |name|
        next if name.downcase == 'n/a'

        group = PoliticalGroup.where('lower(name) = ?', name.downcase).first
        group || PoliticalGroup.create!(name: name)
      end.compact
    end

    def parse_boolean(value)
      value.to_s == '1'
    end

    def strip_html(value)
      return unless value.present?

      value.gsub(/<[^>]*>/ui, '')
    end
  end
end
