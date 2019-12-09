module CCLOW
  class TargetDecorator < Draper::Decorator
    delegate_all

    def link
      h.link_to(model.description, h.cclow_geography_climate_targets_path(model.geography))
    end

    def as_json(*)
      super.tap do |hash|
        hash['link'] = link
      end
    end
  end
end
