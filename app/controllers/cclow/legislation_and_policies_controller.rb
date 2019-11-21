module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    include SearchController
    
    def index
      if (params[:fromDate])
        @legislations = CCLOW::LegislationDecorator.decorate_collection(Legislation.where('date_passed >= ?', params[:fromDate]))
      elsif (params[:ids])
        ids = params[:ids].split(',').map(&:to_i)
        @legislations = CCLOW::LegislationDecorator.decorate_collection(Legislation.find(ids))
      else 
        @legislations = CCLOW::LegislationDecorator.decorate_collection(Legislation.all)
      end
    end
  end
end
