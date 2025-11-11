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
        return @assessment_indicators if defined?(@assessment_indicators)

        pillar_order = %w[EP CP CF]
        areas = ::ASCOR::AssessmentIndicator.where(indicator_type: 'area').order('length(code), code').to_a
        indicators = ::ASCOR::AssessmentIndicator.where(indicator_type: 'indicator').order(:id).to_a
        metrics = ::ASCOR::AssessmentIndicator.where(indicator_type: 'metric').order(:id).to_a

        areas_by_pillar = areas.group_by { |a| a.code.to_s.split('.').first }
        indicators_by_area = indicators.group_by { |i| i.code.to_s.split('.')[0..1].join('.') }
        metrics_by_indicator = metrics.group_by { |m| m.code.to_s.split('.')[0..2].join('.') }

        ordered = []
        pillar_order.each do |pillar_key|
          (areas_by_pillar[pillar_key] || []).each do |area|
            ordered << area
            (indicators_by_area[area.code.to_s] || []).each do |ind|
              ordered << ind
              (metrics_by_indicator[ind.code.to_s] || []).each { |m| ordered << m }
            end
          end
        end

        @assessment_indicators = ordered
      end
    end
  end
end
