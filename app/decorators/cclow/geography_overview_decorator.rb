module CCLOW
  class GeographyOverviewDecorator < Draper::Decorator
    delegate_all

    def number_of_laws
      model.legislations.laws.count
    end

    def number_of_policies
      model.legislations.policies.count
    end

    def number_of_litigation_cases
      model.litigations.count
    end

    def number_of_targets
      model.targets.count
    end

    def legislative_process_preview
      h.truncate(model.legislative_process,
                 length: 645,
                 omission: h.content_tag(:label,
                                         "Read more about #{model.name}’s legislative process  >>",
                                         for: 'legislative-process-toggle',
                                         class: 'highlight read-more-process'),
                 escape: false)
    end
  end
end
