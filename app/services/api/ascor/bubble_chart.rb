module Api
  module ASCOR
    class BubbleChart
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
          .includes(assessment: :country)
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
        recent_emission_level = recent_emission_levels[country_id]&.first&.recent_emission_level
        return :small if recent_emission_level.blank?

        market_cap_groups.find { |range, _| range.include?(recent_emission_level) }&.last || :small
      end

      def pillars
        ::ASCOR::AssessmentIndicator.where(indicator_type: :pillar).group_by(&:code)
      end

      def recent_emission_levels
        @recent_emission_levels ||= ::ASCOR::Pathway.where(MARKET_CAP_QUERY).where(assessment_date: assessment_date)
          .select(:country_id, :recent_emission_level)
          .group_by(&:country_id)
      end

      def market_cap_groups
        @market_cap_groups ||= begin
          min = ::ASCOR::Pathway.where(MARKET_CAP_QUERY).where(assessment_date: assessment_date).minimum(:recent_emission_level)
          max = ::ASCOR::Pathway.where(MARKET_CAP_QUERY).where(assessment_date: assessment_date).maximum(:recent_emission_level)
          step = (max.to_f - min.to_f) / 3
          {min..min + step => :small, min + step..min + (2 * step) => :medium, min + (2 * step)..max => :large}
        end
      end
    end
  end
end
