module CSVExport
  module ASCOR
    class Assessments
      def call
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          assessments.each do |assessment|
            csv << [
              assessment.id,
              assessment.assessment_date,
              assessment.publication_date,
              assessment.country_id,
              assessment.country.name,
              *answer_values_for(assessment),
              *source_values_for(assessment),
              *year_values_for(assessment),
              assessment.notes
            ]
          end
        end
      end

      private

      def headers
        result = ['Id', 'Assessment date', 'Publication date', 'Country Id', 'Country']
        result += assessment_indicators.reject { |i| i.indicator_type == 'pillar' || i.code.in?(%w[EP.1.a.i EP.1.a.ii]) }
          .map { |i| "#{i.indicator_type} #{i.code}" }
        result += assessment_indicators.select { |i| i.indicator_type.in?(%w[indicator metric]) }
          .map { |i| "source #{i.indicator_type} #{i.code}" }
        result += assessment_indicators.select { |i| i.indicator_type == 'metric' }
          .map { |i| "year #{i.indicator_type} #{i.code}" }
        result += ['Notes']
        result
      end

      def answer_values_for(assessment)
        assessment_indicators.reject { |i| i.indicator_type == 'pillar' || i.code.in?(%w[EP.1.a.i EP.1.a.ii]) }
          .map do |indicator|
          assessment_results[[assessment.id, indicator.id]]&.first&.answer
        end
      end

      def source_values_for(assessment)
        assessment_indicators.select { |i| i.indicator_type.in?(%w[indicator metric]) }
          .map do |indicator|
          assessment_results[[assessment.id, indicator.id]]&.first&.source
        end
      end

      def year_values_for(assessment)
        assessment_indicators.select { |i| i.indicator_type == 'metric' }
          .map do |indicator|
          assessment_results[[assessment.id, indicator.id]]&.first&.year
        end
      end

      def assessments
        @assessments ||= ::ASCOR::Assessment.joins(:country).includes(:country)
          .where(ascor_countries: {visibility_status: 'published'}).order(:assessment_date, 'ascor_countries.name')
      end

      def assessment_results
        @assessment_results ||= ::ASCOR::AssessmentResult.all.group_by { |r| [r.assessment_id, r.indicator_id] }
      end

      def assessment_indicators
        @assessment_indicators ||= ::ASCOR::AssessmentIndicator.order(:id)
      end
    end
  end
end
