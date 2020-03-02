module CCLOW
  module Geography
    class LitigationCasesController < CCLOWController
      include GeographyController
      before_action :set_litigation, :redirect_if_numeric_or_historic_slug, only: [:show]

      def index
        add_breadcrumb('Litigation cases', request.path)
        @litigations = @geography.litigations.published.includes(:events)
        @litigations = CCLOW::LitigationDecorator.decorate_collection(@litigations)

        fixed_navbar(
          "Litigation cases - #{@geography.name}",
          admin_litigations_path('q[geography_id_eq]': @geography)
        )
      end

      def show
        add_breadcrumb('Litigation cases', cclow_geography_litigation_cases_path(@geography.slug))
        add_breadcrumb(@litigation.title, request.path)
        @sectors = @litigation.laws_sectors.order(:name)
        @keywords = @litigation.keywords.order(:name)
        @responses = @litigation.responses.order(:name)
        @litigation_sides = @litigation.litigation_sides.map { |ls| CCLOW::LitigationSideDecorator.decorate(ls) }
        @litigation_events = @litigation.events.order(:date)
        @litigation_events_with_links = @litigation_events.map do |e|
          ::Api::Presenters::Event.call(e, :litigation)
        end

        fixed_navbar(
          "Litigation cases - #{@geography.name} - #{@litigation.title}",
          admin_litigation_path(@litigation)
        )
      end

      private

      def set_litigation
        @litigation = @geography.litigations.friendly.find(params[:id])
      end

      def redirect_if_numeric_or_historic_slug
        path = cclow_geography_litigation_case_path(@geography.slug, @litigation.slug)
        redirect_to path, status: :moved_permanently if params[:id] != @litigation.slug
      end
    end
  end
end
