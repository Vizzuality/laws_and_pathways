module CCLOW
  class LegislationDecorator < Draper::Decorator
    delegate_all

    def link
      return h.link_to(title, h.cclow_geography_law_path(geography.slug, model)) if law?

      h.link_to(title, h.cclow_geography_policy_path(geography.slug, model)) if policy?
    end

    def geography_path
      return nil if geography.nil?

      h.cclow_geography_path(geography.slug)
    end

    def short_description
      h.truncate(
        h.strip_tags(description),
        length: 300
      )
    end

    def as_json(*)
      super.tap do |hash|
        hash['link'] = link
        hash['short_description'] = short_description
        hash['geography'] = model.geography
        hash['date_passed'] = model.first_event&.date&.strftime('%Y')
        hash['last_change'] = model.last_event&.date&.strftime('%B, %Y')
        hash['legislation_type'] = model.legislation_type
        hash['legislation_type_humanize'] = model.legislation_type.humanize
        hash['geography_path'] = geography_path
      end
    end
  end
end
