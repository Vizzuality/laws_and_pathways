module CCLOW
  module Geography
    class LitigationCasesController < CCLOWController
      include GeographyController
      include SearchController

      def index
        add_breadcrumb('Litigation cases', request.path)
        @litigations = @geography.litigations.published
      end

      def show
        @litigation = Litigation.find(params[:id])
        @legislations = CCLOW::LegislationDecorator.decorate_collection(@litigation.legislations)
        add_breadcrumb('Litigation cases', cclow_geography_litigation_cases_path(@geography))
        add_breadcrumb(@litigation.title, request.path)
        @sectors = @litigation.laws_sectors
        @keywords = @litigation.keywords
      end
    end
  end
end
