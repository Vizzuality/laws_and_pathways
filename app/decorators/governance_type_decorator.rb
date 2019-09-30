class GovernanceTypeDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_governance_type_path(model)
  end
end
