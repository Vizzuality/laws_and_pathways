class PageDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.send(model.admin_path, model)
  end

  def description
    model.description&.html_safe
  end

  def preview_url
    domain = Rails.configuration.try(model.is_a?(TPIPage) ? :tpi_domain : :cclow_domain)

    "https://#{domain}/#{slug}"
  end
end
