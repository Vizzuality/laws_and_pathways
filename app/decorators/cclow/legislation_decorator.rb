module CCLOW
  class LegislationDecorator < Draper::Decorator
    delegate_all

    def link
      return h.link_to(title, h.cclow_geography_law_path(geography, model)) if law?

      h.link_to(title, h.cclow_geography_policy_path(geography, model)) if policy?
    end

    def as_json(*)
      super.tap do |hash|
        hash['link'] = link
      end
    end
  end
end
