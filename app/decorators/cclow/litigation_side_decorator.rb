module CCLOW
  class LitigationSideDecorator < Draper::Decorator
    delegate_all

    def frontend_name
      return h.link_to name, connected_entity_frontend_url if connected_entity.present?

      name
    end

    private

    def connected_entity_frontend_url
      return h.cclow_geography_path(connected_entity) if connected_entity.is_a?(Geography)
    end
  end
end
