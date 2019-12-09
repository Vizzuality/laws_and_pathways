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
      end
    end
  end
end
