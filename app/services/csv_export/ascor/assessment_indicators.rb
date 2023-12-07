module CSVExport
  module ASCOR
    class AssessmentIndicators
      HEADERS = ['Id', 'Type', 'Code', 'Text', 'Units or response type'].freeze

      def call
        # BOM UTF-8
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << HEADERS

          assessment_indicators.each do |indicator|
            csv << [
              indicator.id,
              indicator.indicator_type,
              indicator.code,
              indicator.text,
              indicator.units_or_response_type
            ]
          end
        end
      end

      private

      def assessment_indicators
        @assessment_indicators ||= ::ASCOR::AssessmentIndicator.order(:id)
      end
    end
  end
end
