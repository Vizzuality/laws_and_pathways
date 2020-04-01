module CCLOW
  class GeographyOverviewDecorator < Draper::Decorator
    delegate_all

    def number_of_laws
      legislations.published.laws.count
    end

    def number_of_policies
      legislations.published.policies.count
    end

    def number_of_litigation_cases
      litigations.published.count
    end

    def number_of_targets
      targets.published.count
    end

    def legislative_process_preview
      h.truncate(legislative_process,
                 length: 645,
                 omission: h.content_tag(:label,
                                         for: 'legislative-process-toggle',
                                         class: 'highlight read-more-process') do
                                           h.content_tag(:span,
                                                         'Read more >>',
                                                         class: 'is-hidden-desktop') +
                                           h.content_tag(:span,
                                                         "Read more about #{model.name}’s legislative process  >>",
                                                         class: 'is-hidden-touch')
                                         end,
                 escape: false)
    end
  end
end
