class CP::AssessmentDecorator < Draper::Decorator
  delegate_all

  def title
    "#{model.cp_assessmentable.name} (#{assessment_date})"
  end

  def title_link
    h.link_to title, h.admin_cp_assessment_path(model)
  end

  def assessment_date
    model.assessment_date || 'No date'
  end

  def publication_date
    model.publication_date.to_s(:month_name_and_year)
  end

  def publication_date_csv
    model.publication_date.to_s(:year_month)
  end

  def years_with_targets_csv
    model.years_with_targets&.join(Rails.application.config.csv_options[:entity_sep])
  end
end
