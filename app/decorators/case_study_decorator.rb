class CaseStudyDecorator < Draper::Decorator
  delegate_all

  def logo
    h.image_tag h.url_for(model.logo)
  end

  def link
    h.link_to model.link, model.link
  end

  def organization_link
    h.link_to organization, h.admin_case_study_path(model)
  end
end
