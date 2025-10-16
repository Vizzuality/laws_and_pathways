module Api
  module Charts
    class AverageBankScore
      def average_bank_score_data(date = nil)
        scope = BankAssessmentResult.of_type(:area)
        scope = scope.by_date(date) if date.present?

        version = determine_version_for_date(date)
        scope = scope.with_version(version)

        area_results = scope
          .group(:number, :text)
          .order('length(bank_assessment_indicators.number), bank_assessment_indicators.number')
          .average(:percentage)
          .transform_keys { |number, text| "#{number}. #{text}" }
          .transform_values(&:to_f)
          .to_a

        if area_results.empty?
          area_results = BankAssessmentIndicator.by_version(version).where(indicator_type: 'area')
            .order(Arel.sql('length(number), number'))
            .map { |i| ["#{i.number}. #{i.text}", 0.0] }
        end

        [
          {
            name: 'Bank average scores',
            data: area_results
          }
        ]
      end

      private

      def determine_version_for_date(date)
        return '2024' if date.blank?

        # Convert string to Date if needed
        parsed_date = date.is_a?(String) ? Date.parse(date) : date
        return '2025' if parsed_date >= Date.new(2025, 1, 1)
        return '2024' if parsed_date >= Date.new(2024, 1, 1)

        '2024'
      end
    end
  end
end
