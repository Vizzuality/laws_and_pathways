class PageDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_page_path(model)
  end

  def description
    model.description.html_safe
  end
end
