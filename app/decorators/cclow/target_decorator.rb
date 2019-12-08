module CCLOW
  class TargetDecorator < Draper::Decorator
    delegate_all

    def link
      h.link_to(model, h.cclow_geography_climate_targets_path(model.geography))
    end
  end
end
