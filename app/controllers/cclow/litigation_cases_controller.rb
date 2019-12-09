module CCLOW
  class LitigationCasesController < CCLOWController
    include SearchController

    def index
      add_breadcrumb('Litigation cases', cclow_litigation_cases_path(@geography))
      if params[:ids]
        ids = params[:ids].split(',').map(&:to_i)
        @litigations = CCLOW::LitigationDecorator.decorate_collection(Litigation.find(ids))
        add_breadcrumb('Search results', request.path)
      else
        @litigations = CCLOW::LitigationDecorator.decorate_collection(Litigation.published)
      end
    end
  end
end
