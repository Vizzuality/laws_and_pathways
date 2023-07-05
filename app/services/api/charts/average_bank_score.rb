module Api
  module Charts
    class AverageBankScore
      def average_bank_score_data
        area_results = BankAssessmentResult.of_type(:area)
          .group(:number, :text)
          .order('length(bank_assessment_indicators.number), bank_assessment_indicators.number')
          .average(:percentage)
          .transform_keys { |number, text| "#{number}. #{text}" }
          .transform_values(&:to_f)
          .to_a

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
