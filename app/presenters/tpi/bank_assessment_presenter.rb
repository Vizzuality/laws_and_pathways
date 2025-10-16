module TPI
  class BankAssessmentPresenter
    attr_reader :assessment

    delegate :results, :indicator_version, to: :assessment

    def initialize(assessment)
      @assessment = assessment
    end

    def child_indicators(result, indicator_type)
      return [] unless results_by_indicator_type[indicator_type]

      results_by_indicator_type[indicator_type].select { |r| r.indicator.number.start_with?("#{result.indicator.number}.") }
    end

    def results_by_indicator_type
      @results_by_indicator_type ||= @assessment&.results_by_indicator_type || {}
    end

    def all_results_by_indicator_type
      @all_results_by_indicator_type ||= @assessment&.all_results_by_indicator_type || {}
    end

    def average_bank_score
      @average_bank_score ||= BankAssessmentResult
        .by_date(@assessment.assessment_date)
        .of_type(:area)
        .with_version(@assessment.indicator_version)
        .group(:text)
        .average(:percentage)
        .transform_values(&:to_f)
    end

    def max_bank_score
      @max_bank_score ||= BankAssessmentResult
        .by_date(@assessment.assessment_date)
        .of_type(:area)
        .with_version(@assessment.indicator_version)
        .group(:text)
        .maximum(:percentage)
    end
  end
end
