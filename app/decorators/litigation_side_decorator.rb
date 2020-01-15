class LitigationSideDecorator < Draper::Decorator
  delegate_all

  def name
    return h.link_to model.name, connected_entity_url if connected_entity.present?

    model.name
  end

  def frontend_name
    return h.link_to model.name, connected_entity_frontend_url if connected_entity.present?

    model.name
  end

  def party_type
    model.party_type&.humanize
  end

  def side_type
    model.side_type&.humanize
  end

  private

  def connected_entity_url
    return h.admin_company_path(connected_entity) if connected_entity.is_a?(Company)
    return h.admin_geography_path(connected_entity) if connected_entity.is_a?(Geography)
  end

  def connected_entity_frontend_url
    return h.cclow_geography_path(connected_entity) if connected_entity.is_a?(Geography)
  end
end
