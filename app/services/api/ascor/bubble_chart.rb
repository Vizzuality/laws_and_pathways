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
        area_results_by_indicator_id = ::ASCOR::AssessmentResult
          .by_date(@assessment_date)
          .of_type(:area)
          .published
          .includes(:indicator, assessment: :country)
          .group_by(&:indicator_id)

        output = []

        pillars_in_order.each do |pillar|
          areas_for_pillar(pillar.code).each do |area|
            entries = area_results_by_indicator_id[area.id]

            if entries.present?
              entries.each do |result|
                output << {
                  pillar: pillar.text,
                  area: area.text,
                  result: result.answer,
                  country_id: result.assessment.country_id,
                  country_name: result.assessment.country.name,
                  country_path: result.assessment.country.path,
                  market_cap_group: calculate_market_cap_group(result.assessment.country_id)
                }
              end
            else
              output << {
                pillar: pillar.text,
                area: area.text,
                result: 'N/A',
                country_id: 0,
                country_name: '',
                country_path: '',
                market_cap_group: 1
              }
            end
          end
        end

        output
      end

      private

      def calculate_market_cap_group(country_id)
        recent_emission_level = recent_emission_levels[country_id]&.first&.recent_emission_level.to_f
        return 1 if recent_emission_level.blank?

        market_cap_groups.find { |range, _| range.include?(recent_emission_level) }&.last || 1
      end

      def pillars_in_order
        @pillars_in_order ||= versioned_indicators.select(&:pillar?).sort_by(&:id)
      end

      def areas_for_pillar(pillar_code)
        @areas_by_pillar ||= versioned_indicators
          .select(&:area?)
          .sort_by { |i| [i.code.length, i.code] }
          .group_by { |i| i.code.split('.').first }
        @areas_by_pillar[pillar_code] || []
      end

      def versioned_indicators
        @versioned_indicators ||= begin
          # 1. Try exact date match
          versioned = ::ASCOR::AssessmentIndicator.where(assessment_date: assessment_date).to_a
          return versioned if versioned.any?

          # 2. Try most recent date <= assessment_date
          if assessment_date.present?
            latest_date = ::ASCOR::AssessmentIndicator.where('assessment_date <= ?', assessment_date).maximum(:assessment_date)
            return ::ASCOR::AssessmentIndicator.where(assessment_date: latest_date).to_a if latest_date.present?
          end

          # 3. Fall back to indicators with no date
          no_date = ::ASCOR::AssessmentIndicator.where(assessment_date: nil).to_a
          return no_date if no_date.any?

          # 4. Last resort: most recent available
          latest_available = ::ASCOR::AssessmentIndicator.maximum(:assessment_date)
          ::ASCOR::AssessmentIndicator.where(assessment_date: latest_available).to_a
        end
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
