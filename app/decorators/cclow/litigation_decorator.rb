module CCLOW
  class LitigationDecorator < Draper::Decorator
    delegate_all

    def link
      if geography
        h.link_to(title, h.cclow_geography_litigation_case_path(geography.slug, model))
      else
        title
      end
    end

    def short_summary
      h.truncate(
        h.strip_tags(summary),
        length: 300
      )
    end

    def geography_path
      return nil if geography.nil?

      h.cclow_geography_path(geography.slug)
    end

    def as_json(*)
      super.tap do |hash|
        hash['link'] = link
        hash['short_summary'] = short_summary
        hash['geography'] = model.geography
        hash['opened_in'] = model.started_event&.date&.year
        hash['last_development_in'] = model.last_non_starting_event&.date&.strftime('%B, %Y')
        hash['event_type'] = model.started_event&.event_type
        hash['geography_path'] = geography_path
      end
    end
  end
end
