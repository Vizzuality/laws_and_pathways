module TPI
  class CompanyDecorator < Draper::Decorator
    delegate_all

    def name
      return model.name if model.active

      "#{model.name} (Not active)"
    end
  end
end
