class TargetScopeDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_target_scope_path(model)
  end
end
