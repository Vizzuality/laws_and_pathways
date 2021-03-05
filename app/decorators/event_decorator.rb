class EventDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_event_path(model)
  end

  def url_link
    return unless model.url.present?

    h.link_to model.url, model.url, target: '_blank', rel: 'noopener noreferrer'
  end

  def event_type
    model.event_type.titleize
  end
end
