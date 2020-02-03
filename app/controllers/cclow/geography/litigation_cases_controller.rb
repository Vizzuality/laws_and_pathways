module CCLOW
  module Geography
    class LitigationCasesController < CCLOWController
      include GeographyController

      def index
        add_breadcrumb('Litigation cases', request.path)
        @litigations = @geography.litigations.published.includes(:events)
        @litigations = CCLOW::LitigationDecorator.decorate_collection(@litigations)

        fixed_navbar(
          "Litigation cases - #{@geography.name}",
          admin_litigations_path('q[geography_id_eq]': @geography)
        )
      end

      # rubocop:disable Metrics/AbcSize
      def show
        @litigation = @geography.litigations.find(params[:id])
        @legislations = CCLOW::LegislationDecorator.decorate_collection(@litigation.legislations)
        add_breadcrumb('Litigation cases', cclow_geography_litigation_cases_path(@geography))
        add_breadcrumb(@litigation.title, request.path)
        @sectors = @litigation.laws_sectors.order(:name)
        @keywords = @litigation.keywords.order(:name)
        @responses = @litigation.responses.order(:name)
        @litigation_sides = @litigation.litigation_sides.map { |ls| CCLOW::LitigationSideDecorator.decorate(ls) }
        @litigation_events = @litigation.events.order(:date)
        @litigation_events_with_links = @litigation_events.map do |e|
          ::Api::Presenters::Event.call(e, :litigation)

          fixed_navbar(
            "Litigation cases - #{@geography.name} - #{@litigation.title}",
            admin_litigation_path(@litigation)
          )
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
