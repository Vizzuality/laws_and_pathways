module CCLOW
  class TargetDecorator < Draper::Decorator
    delegate_all

    # rubocop:disable Metrics/AbcSize
    def link
      link_title = model.description || [model.target_type.humanize, model.year].compact.join(', ')

      if model.sector
        h.link_to(link_title,
                  h.cclow_geography_geography_climate_targets_sector_path(model.geography.slug,
                                                                          model.sector.name))
      else
        h.link_to(link_title, h.cclow_geography_climate_targets_path(model.geography))
      end
    end
    # rubocop:enable Metrics/AbcSize

    def target_tags
      target_tags = [model.sector&.name, model.target_type&.humanize]
      target_tags << "Target year: #{model.year}" if model.year
      target_tags << "Base year: #{model.base_year_period}" if model.base_year_period
      target_tags.compact
    end

    def geography_path
      return nil if geography.nil?

      h.cclow_geography_path(geography.slug)
    end

    def as_json(*)
      super.tap do |hash|
        hash['link'] = link
        hash['geography'] = model.geography
        hash['target_tags'] = target_tags
        hash['geography_path'] = geography_path
      end
    end
  end
end
