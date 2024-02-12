module Api
  module ASCOR
    class BubbleChart
      NUMBER_OF_MARKET_CAP_GROUPS = 4
      MARKET_CAP_QUERY = {
        emissions_metric: 'Intensity per capita',
        emissions_boundary: 'Production - excluding LULUCF'
      }.freeze

      attr_accessor :assessment_date

      def initialize(assessment_date)
        @assessment_date = assessment_date
      end

      def call
        ::ASCOR::AssessmentResult
          .by_date(@assessment_date)
          .of_type(:area)
          .published
          .order(:indicator_id)
          .map do |result|
          {
            pillar: pillars[result.indicator.code.split('.').first]&.first&.text,
            area: result.indicator.text,
            result: result.answer,
            country_id: result.assessment.country_id,
            country_name: result.assessment.country.name,
            country_path: result.assessment.country.path,
            market_cap_group: calculate_market_cap_group(result.assessment.country_id)
          }
        end
      end

      private

      def calculate_market_cap_group(country_id)
        recent_emission_level = recent_emission_levels[country_id]&.first&.recent_emission_level.to_f
        return 1 if recent_emission_level.blank?

        market_cap_groups.find { |range, _| range.include?(recent_emission_level) }&.last || 1
      end

      def pillars
        @pillars ||= ::ASCOR::AssessmentIndicator.where(indicator_type: :pillar).group_by(&:code)
      end

      def recent_emission_levels
        @recent_emission_levels ||= ::ASCOR::Pathway.where(MARKET_CAP_QUERY).where(assessment_date: assessment_date)
          .select(:country_id, :recent_emission_level)
          .group_by(&:country_id)
      end

      def market_cap_groups
        @market_cap_groups ||= begin
          values = ::ASCOR::Pathway.where(MARKET_CAP_QUERY).where(assessment_date: assessment_date)
            .pluck(:recent_emission_level).map(&:to_f).compact.sort
          NUMBER_OF_MARKET_CAP_GROUPS.times.each_with_object({}) do |i, result|
            next if values.empty?

            result[values[cap_index_for(i, values.size)]..values[cap_index_for(i + 1, values.size)]] = i + 1
          end
        end
      end

      def cap_index_for(index, size)
        return 0 if index.zero?

        (size * index / NUMBER_OF_MARKET_CAP_GROUPS.to_f).ceil - 1
      end
    end
  end
end
