class LitigationSideDecorator < Draper::Decorator
  delegate_all

  def name
    return h.link_to model.name, h.admin_company_path(company) if company.present?
    return h.link_to model.name, h.admin_location_path(location) if location.present?

    model.name
  end

  def party_type
    model.party_type&.humanize
  end

  def side_type
    model.side_type&.humanize
  end
end
