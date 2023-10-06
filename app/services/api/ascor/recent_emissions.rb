module Api
  module ASCOR
    class RecentEmissions
      attr_accessor :assessment_date, :country

      def initialize(assessment_date, country)
        @assessment_date = assessment_date
        @country = country
      end

      def call
        pathways.map do |pathway|
          {
            value: pathway.recent_emission_level,
            source: pathway.recent_emission_source,
            year: pathway.recent_emission_year,
            emissions_metric: pathway.emissions_metric,
            emissions_boundary: pathway.emissions_boundary,
            unit: pathway.units,
            trend: {
              source: pathway.trend_source,
              year: pathway.trend_year,
              values: [
                {filter: '1 year trend', value: pathway.trend_1_year},
                {filter: '3 years trend', value: pathway.trend_3_year},
                {filter: '5 years trend', value: pathway.trend_5_year}
              ]
            }
          }
        end
      end

      private

      def pathways
        @pathways ||= ::ASCOR::Pathway.where(assessment_date: assessment_date, country: country)
      end
    end
  end
end
