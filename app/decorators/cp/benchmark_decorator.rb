class CP::BenchmarkDecorator < Draper::Decorator
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
end
