class CCLOWMapContextData
  class << self
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength

    ROUND_VALUES = %w(USD %).freeze

    def all
      datasets = Dir.glob('map_data/*.csv')
      datasets_map = datasets.each_with_object({}) do |file, hash|
        hash[file.split('/')[1].split('.')[0]] = file
      end

      parsed = datasets_map.sort.to_h.map do |key, dataset|
        csv_file = File.read(dataset)
        metadata_file = File.read(Rails.root.join('map_data', "#{key}.yml"))
        metadata = YAML.safe_load(metadata_file)

        next unless metadata['active']

        value_column = metadata['value_column']

        parse_value = if ROUND_VALUES.include?(metadata['unit'])
                        ->(value) { value.to_f.round(2) }
                      else
                        ->(value) { value.to_f }
                      end

        parsed_data = CSV.parse(
          csv_file,
          headers: true,
          header_converters: :symbol,
          skip_blanks: true
        )

        data = parsed_data.map do |row|
          {
            geography_iso: row[:iso3],
            value: parse_value.call(row[value_column.to_sym])
          }
        end

        eu_countries_data = data.select do |el|
          ::Geography::EU_COUNTRIES.include?(el[:geography_iso])
        end

        eu_aggregated_value = eu_countries_data.pluck(:value).reduce(:+)
        data << {geography_iso: 'EUR', value: eu_aggregated_value}

        {
          id: key,
          values: data
        }.merge(metadata)
      end
      parsed.compact
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def check_data_integrity
      all_geographies = Geography.all

      all.each do |indicator|
        indicator[:values].each do |value|
          unless all_geographies.find { |g| g.iso == value[:geography_iso] }
            puts "#{indicator[:id]}: Geography with iso #{value[:geography_iso]} does not exist"
          end
        end
      end

      nil
    end
  end
end
