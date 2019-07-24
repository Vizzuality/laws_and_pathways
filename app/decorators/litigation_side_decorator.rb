class LitigationSideDecorator < Draper::Decorator
  delegate_all

  def name
    return h.link_to company.name, h.admin_company_path(company) if company?
    return h.link_to location.name, h.admin_location_path(location) if location?

    model.name
  end

  def party_type
    model.party_type&.humanize
  end

  def side_type
    model.side_type&.humanize
  end
end
