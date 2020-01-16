module CCLOW
  module Geography
    class LitigationCasesController < CCLOWController
      include GeographyController

      def index
        add_breadcrumb('Litigation cases', request.path)
        @litigations = @geography.litigations.published.includes(:events)
        @litigations = CCLOW::LitigationDecorator.decorate_collection(@litigations)
      end

      def show
        @litigation = Litigation.find(params[:id])
        @legislations = CCLOW::LegislationDecorator.decorate_collection(@litigation.legislations)
        add_breadcrumb('Litigation cases', cclow_geography_litigation_cases_path(@geography))
        add_breadcrumb(@litigation.title, request.path)
        @sectors = @litigation.laws_sectors.order(:name)
        @keywords = @litigation.keywords.order(:name)
        @responses = @litigation.responses.order(:name)
        @litigation_sides = @litigation.litigation_sides.map { |ls| CCLOW::LitigationSideDecorator.decorate(ls) }
        @litigation_events = @litigation.events_with_eventable_title
      end
    end
  end
end
