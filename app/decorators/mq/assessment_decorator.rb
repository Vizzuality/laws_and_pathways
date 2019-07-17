class MQ::AssessmentDecorator < Draper::Decorator
  delegate_all

  def title
    "Assessement taken on #{model.assessment_date}"
  end

  def publication_date
    model.publication_date.to_s(:month_and_year)
  end
end
