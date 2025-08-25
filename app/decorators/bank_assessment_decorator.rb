class BankAssessmentDecorator < Draper::Decorator
  delegate_all

  def title
    "#{model.bank.name} (#{assessment_date})"
  end

  def title_link
    h.link_to title, h.admin_bank_assessment_path(model)
  end

  def assessment_date
    model.assessment_date || 'No date'
  end

  def taken_on
    "Assessement taken on #{model.assessment_date}"
  end

  def results
    # Use only active indicators by default
    model.results.joins(:indicator).where(bank_assessment_indicators: {active: true}).order('bank_assessment_indicators.number')
  end

  def all_results
    # Method to get all results (including inactive indicators)
    model.results.includes(:indicator).order('bank_assessment_indicators.number')
  end
end
