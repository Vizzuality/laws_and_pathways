class EventDecorator < Draper::Decorator
  delegate_all

  def url_link
    return unless model.url.present?

    h.link_to model.url, model.url, target: '_blank'
  end

  def event_type
    model.event_type.titleize
  end
end
