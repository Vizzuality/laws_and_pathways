module CCLOW
  class LitigationDecorator < Draper::Decorator
    delegate_all

    def link
      h.link_to(title, h.cclow_geography_litigation_case_path(jurisdiction, model))
    end
  end
end
