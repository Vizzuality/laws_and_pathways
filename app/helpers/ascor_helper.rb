module ASCORHelper
  def ascor_icon_for(indicator, assessment)
    value = ascor_assessment_result_for(indicator, assessment).answer.to_s.downcase.tr(' ', '-')
    return 'no-data' unless value.in?(%w[yes no partial no-data no-disclosure not-applicable exempt])

    value
  end

  def ascor_sub_indicators_for(indicator, sub_indicators)
    sub_indicators.select { |i| i.code.include? indicator.code }
  end

  def ascor_assessment_result_for(indicator, assessment)
    assessment.results.find { |r| r.indicator_id == indicator.id }
  end
end
