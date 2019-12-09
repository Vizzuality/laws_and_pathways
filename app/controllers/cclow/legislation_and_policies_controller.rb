module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    include SearchController

    def index
      add_breadcrumb('Legislation and policies', cclow_legislation_and_policies_path(@geography))
      if params[:fromDate]
        @legislations = CCLOW::LegislationDecorator
          .decorate_collection(Legislation.published.where('updated_at >= ?', params[:fromDate]))
      elsif params[:ids]
        ids = params[:ids].split(',').map(&:to_i)
        @legislations = CCLOW::LegislationDecorator.decorate_collection(Legislation.published.find(ids))
        add_breadcrumb('Search results', request.path)
      else
        @legislations = CCLOW::LegislationDecorator.decorate_collection(Legislation.published)
      end
    end
  end
end
