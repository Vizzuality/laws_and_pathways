module CSVExport
  module ASCOR
    class Pathways
      HEADERS = [
        'Id',
        'Country',
        'Emissions metric',
        'Emissions boundary',
        'Units',
        'Assessment date',
        'Publication date',
        'Last historical year',
        'metric EP1.a.i',
        'source metric EP1.a.i',
        'year metric EP1.a.i',
        'metric EP1.a.ii 1-year',
        'metric EP1.a.ii 3-year',
        'metric EP1.a.ii 5-year',
        'source metric EP1.a.ii',
        'year metric EP1.a.ii'
      ].freeze

      def call
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << (HEADERS + year_columns)

          pathways.each do |pathway|
            csv << [
              pathway.id,
              pathway.country.name,
              pathway.emissions_metric,
              pathway.emissions_boundary,
              pathway.units,
              pathway.assessment_date,
              pathway.publication_date,
              pathway.last_historical_year,
              pathway.recent_emission_level,
              pathway.recent_emission_source,
              pathway.recent_emission_year,
              pathway.trend_1_year,
              pathway.trend_3_year,
              pathway.trend_5_year,
              pathway.trend_source,
              pathway.trend_year,
              year_columns.map do |year|
                pathway.emissions[year]
              end
            ].flatten
          end
        end
      end

      private

      def year_columns
        @year_columns ||= pathways.flat_map(&:emissions_all_years).uniq.sort
      end

      def pathways
        @pathways ||= ::ASCOR::Pathway.joins(:country).includes(:country)
          .order(:assessment_date, 'ascor_countries.name')
      end
    end
  end
end
