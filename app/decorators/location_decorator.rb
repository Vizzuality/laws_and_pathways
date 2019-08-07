class LocationDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_location_path(model)
  end

  def federal_details
    model.federal_details&.html_safe
  end

  def legislative_process
    model.legislative_process&.html_safe
  end

  def location_type
    model.location_type.humanize
  end

  def indc_link
    return unless model.indc_url.present?

    h.link_to model.indc_url, model.indc_url, target: '_blank'
  end
end
