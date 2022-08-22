class CaseStudyDecorator < Draper::Decorator
  delegate_all

  def organization_link
    h.link_to organization, h.admin_case_study_path(model)
  end
end
