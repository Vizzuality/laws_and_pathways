module CCLOW
  class LitigationCasesController < CCLOWController
    include GeographyController

    def index
      add_breadcrumb('Litigation cases', request.path)
      @litigations = @geography.litigations
    end

    def show
      @litigation = Litigation.find(params[:id])
      add_breadcrumb('Litigation cases', cclow_geography_litigation_cases_path(@geography))
      add_breadcrumb(@litigation.title, request.path)
    end
  end
end
