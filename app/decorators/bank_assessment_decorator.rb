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
    model.results.includes(:indicator).sort_by { |r| r.indicator.number }
  end
end
