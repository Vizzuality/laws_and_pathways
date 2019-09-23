class MQ::AssessmentDecorator < Draper::Decorator
  delegate_all

  def title
    "#{model.company.name} (#{assessment_date})"
  end

  def title_link
    h.link_to title, h.admin_mq_assessment_path(model)
  end

  def assessment_date
    model.assessment_date || 'No date'
  end

  def taken_on
    "Assessement taken on #{model.assessment_date}"
  end

  def publication_date
    model.publication_date.to_s(:month_name_and_year)
  end

  def publication_date_csv
    model.publication_date.to_s(:year_month)
  end
end
