module Api
  module Charts
    class AverageBankScore
      def average_bank_score_data(date = nil)
        scope = BankAssessmentResult.of_type(:area)
        scope = scope.by_date(date) if date.present?

        area_results = scope
          .group(:number, :text)
          .order('length(bank_assessment_indicators.number), bank_assessment_indicators.number')
          .average(:percentage)
          .transform_keys { |number, text| "#{number}. #{text}" }
          .transform_values(&:to_f)
          .to_a

        if area_results.empty?
          area_results = BankAssessmentIndicator.active.where(indicator_type: 'area')
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
    end
  end
end
