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
        hash['geography'] = model.geography
        hash['date_passed'] = model.date_passed
        hash['legislation_type'] = model.legislation_type
        hash['legislation_type_humanize'] = model.legislation_type.humanize
      end
    end
  end
end
