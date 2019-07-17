class LitigationDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_litigation_path(model)
  end

  def document_type
    model.document_type.humanize
  end

  def summary
    model.summary.html_safe
  end

  def core_objective
    model.core_objective.html_safe
  end
end
