module CCLOW
  module Geography
    class LegislationsController < CCLOWController
      include GeographyController
      before_action :set_legislation, :redirect_if_numeric_or_historic_slug, only: [:show]

      before_action :set_common_breadcrumb

      def index
        @legislations = if show_laws?
                          @geography.legislations.laws
                        else
                          @geography.legislations.policies
                        end
        @legislations = @legislations.published
          .includes(:events)
          .joins(:events).order('events.date DESC')
        @legislations = CCLOW::LegislationDecorator.decorate_collection(@legislations)

        fixed_navbar(
          "Climate Laws and Policies - #{@geography.name}",
          admin_legislations_path(
            'q[geography_id_eq]': @geography,
            'q[legislation_type_eq]': params[:scope] == :laws ? 'legislative' : 'executive'
          )
        )
      end

      def show
        add_breadcrumb(@legislation.title, request.path)
        @sectors = @legislation.laws_sectors.order(:name)
        @keywords = @legislation.keywords.order(:name)
        @responses = @legislation.responses.order(:name)
        @instruments = @legislation.instruments.order(:name)
        legislation_events = @legislation.events.order(:date)
        @legislation_events_with_links = legislation_events.map do |e|
          ::Api::Presenters::Event.call(e, :legislation)
        end

        fixed_navbar(
          "Climate Laws and Policies - #{@geography.name} - #{@legislation.title}",
          admin_legislation_path(@legislation)
        )
      end

      private

      def set_common_breadcrumb
        if show_laws?
          add_breadcrumb('Laws', cclow_geography_laws_path(@geography.slug))
        else
          add_breadcrumb('Policies', cclow_geography_policies_path(@geography.slug))
        end
      end

      def show_laws?
        params[:scope] == :laws
      end

      def set_legislation
        @legislation = CCLOW::LegislationDecorator.new(::Legislation.friendly.find(params[:id]))
      end

      def redirect_if_numeric_or_historic_slug
        path = if show_laws?
                 cclow_geography_law_path(@geography.slug, @legislation.slug)
               else
                 cclow_geography_policy_path(@geography.slug, @legislation.slug)
               end
        redirect_to path, status: :moved_permanently if params[:id] != @legislation.slug
      end
    end
  end
end
