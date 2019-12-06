class CCLOWMapContextData
  DATASETS = {
    total_emissions_fossil_fuels_2018: {
      name: 'Total cumulative carbon emissions (2018)',
      file: 'emissions_total_fossil_fuels_and_cement_in_MtCO2e_2018',
      value_column: :emissions_total_fossil_fuels_and_cement_in_mtco2e_2018
    },
    cumulative_direct_economic_loss_disaters_absolute: {
      name: 'Direct disaster economic loss USD',
      file: 'cumalitive_direct_economic_loss_disasters_in_current_us_dollars_2005--2018',
      value_column: :cumalitive_direct_economic_loss_disasters_in_current_us_dollars
    },
    cumulative_direct_economic_loss_disaters_gdp: {
      name: 'Direct disaster economic loss as a share of GDP',
      file: 'cumalitive_direct_economic_loss_disasters_relative_to_gdp_percent_2005--2018',
      value_column: :cumalitive_direct_economic_loss_disasters_relative_to_gdp_percent
    },
    cumulative_weather_idp: {
      name: 'Cumalitive number of persons iternally displaced due to weather hazards',
      file: 'cumalitive_weather_idp_per_country_2008--2018',
      value_column: :tot_weather_idp
    }
  }.freeze

  class << self
    def all
      DATASETS.map do |key, dataset|
        csv_file = File.read(Rails.root.join('map_data', "#{dataset[:file]}.csv"))
        metadata_file = File.read(Rails.root.join('map_data', "#{dataset[:file]}.jsonld"))
        value_column = dataset[:value_column]

        data = CSV.parse(
          csv_file,
          headers: true,
          header_converters: :symbol,
          skip_blanks: true
        ).map do |row|
          {
            geography_iso: row[:iso3],
            value: row[value_column]
          }
        end

        {
          id: key,
          name: dataset[:name],
          values: data,
          metadata: JSON.parse(metadata_file)
        }
      end
    end

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
