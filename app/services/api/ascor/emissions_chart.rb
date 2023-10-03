module Api
  module ASCOR
    class EmissionsChart
      attr_accessor :assessment_date, :emissions_assessment_date, :emissions_metric, :emissions_boundary, :country_ids

      def initialize(assessment_date, emissions_metric, emissions_boundary, country_ids)
        @assessment_date = assessment_date
        @emissions_metric = emissions_metric || 'Absolute'
        @emissions_boundary = emissions_boundary || 'Production - excluding LULUCF'
        @country_ids = country_ids
      end

      def call
        {data: collect_data, metadata: collect_metadata}
      end

      private

      def collect_data
        countries.each_with_object({}) do |country, result|
          pathway = pathways[country.id]&.first
          result[country.id] = {
            emissions: pathway&.emissions || {},
            last_historical_year: pathway&.last_historical_year
          }
        end
      end

      def collect_metadata
        {unit: pathways.values.flatten.first.units}
      end

      def countries
        @countries ||= if country_ids.blank?
                         ::ASCOR::Country.where(iso: ::ASCOR::Country::DEFAULT_COUNTRIES)
                       else
                         ::ASCOR::Country.where(id: country_ids)
                       end
      end

      def pathways
        @pathways ||= ::ASCOR::Pathway.where(
          country: countries,
          emissions_metric: emissions_metric,
          emissions_boundary: emissions_boundary,
          assessment_date: assessment_date
        ).group_by(&:country_id)
      end
    end
  end
end
