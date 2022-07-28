class BankAssessmentResultDecorator < Draper::Decorator
  delegate_all

  def value
    return model.answer unless model.indicator.percentage_indicator?

    "#{h.number_with_precision(
      model.percentage,
      precision: 2,
      strip_insignificant_zeros: true
    )}%"
  end
end
