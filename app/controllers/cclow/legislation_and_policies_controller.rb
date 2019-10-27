module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    def index
      @legislations = CCLOW::LegislationDecorator.decorate_collection(Legislation.all)
    end
  end
end
