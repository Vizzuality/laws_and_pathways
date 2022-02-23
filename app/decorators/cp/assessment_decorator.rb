class CP::AssessmentDecorator < Draper::Decorator
  delegate_all

  def title
    "#{model.company.name} (#{assessment_date})"
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

  def cp_alignment_year
    return "#{model.cp_alignment_year} (override)" if cp_alignment_year_override.present?

    model.cp_alignment_year
  end
end
