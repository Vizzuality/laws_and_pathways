module ASCORHelper
  def ascor_icon_for(indicator, assessment)
    if indicator.respond_to?(:area?) && indicator.area? && indicator.code == 'EP.3' && assessment.assessment_date.year <= 2024
      return 'not-applicable'
    end

    result = ascor_assessment_result_for(indicator, assessment)
    value = result&.answer.to_s.downcase.tr(' ', '-')
    return 'no-data' unless value.in?(%w[yes no partial no-data no-disclosure not-applicable exempt])

    value
  end

  def ascor_sub_indicators_for(indicator, sub_indicators)
    sub_indicators.select { |i| i.code.include? indicator.code }
  end

  def ascor_assessment_result_for(indicator, assessment)
    # Match by indicator code instead of ID to support versioned indicators
    assessment.results.find { |r| r.indicator.code == indicator.code }
  end
end
