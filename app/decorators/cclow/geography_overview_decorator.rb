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
  end
end
