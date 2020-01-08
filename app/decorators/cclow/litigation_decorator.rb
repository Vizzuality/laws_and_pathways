module CCLOW
  class LitigationDecorator < Draper::Decorator
    delegate_all

    def link
      if geography
        h.link_to(title, h.cclow_geography_litigation_case_path(geography, model))
      else
        title
      end
    end

    def as_json(*)
      super.tap do |hash|
        hash['link'] = link
        hash['geography'] = model.geography
        hash['opened_in'] = model.started_event&.date&.year
        hash['last_development_in'] = model.last_non_starting_event&.date&.strftime('%m, %Y')
        hash['event_type'] = model.started_event&.event_type
      end
    end
  end
end
