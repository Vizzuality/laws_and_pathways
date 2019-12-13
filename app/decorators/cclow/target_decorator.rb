module CCLOW
  class TargetDecorator < Draper::Decorator
    delegate_all

    def link
      h.link_to(model.description, h.cclow_geography_climate_targets_path(model.geography))
    end

    def target_tags
      target_tags = [model.sector&.name, model.target_type&.humanize]
      target_tags << "Target year: #{model.year}" if model.year
      target_tags << "Base year: #{model.base_year_period}" if model.base_year_period
      target_tags.compact
    end

    def as_json(*)
      super.tap do |hash|
        hash['link'] = link
        hash['geography'] = model.geography
        hash['target_tags'] = target_tags
      end
    end
  end
end
