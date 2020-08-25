class PageDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.send(model.admin_path, model)
  end

  def description
    model.description&.html_safe
  end

  def preview_url
    return "/tpi/#{slug}" if model.is_a?(TPIPage)

    "/cclow/#{slug}"
  end
end
