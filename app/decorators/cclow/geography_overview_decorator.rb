module CCLOW
  class GeographyOverviewDecorator < Draper::Decorator
    delegate_all

    def number_of_laws
      model.legislations.legislative.count
    end

    def number_of_policies
      model.legislations.executive.count
    end

    def number_of_litigation_cases
      model.litigations.count
    end
  end
end
