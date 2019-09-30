class GovernanceDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_governance_path(model)
  end
end
