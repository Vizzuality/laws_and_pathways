class ThemeDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_theme_path(model)
  end
end
