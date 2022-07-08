module Api
  module Charts
    class AverageBankScore
      def average_bank_score_data
        area_results = BankAssessmentResult.of_type(:area)
          .group(:text)
          .average(:percentage)
          .to_a
          .map { |a| [a[0], a[1].to_f] }

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
