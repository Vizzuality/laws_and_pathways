module CCLOW
  module Geography
    class LegislationsController < CCLOWController
      include GeographyController

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

        @admin_panel_section_title = "Climate Laws and Policies - #{@geography.name}"
        @link = admin_legislations_path(
          'q[geography_id_eq]': @geography,
          'q[legislation_type_eq]': params[:scope] == :laws ? 'legislative' : 'executive'
        )
      end

      def show
        @legislation = CCLOW::LegislationDecorator.new(::Legislation.find(params[:id]))
        add_breadcrumb(@legislation.title, request.path)
        @sectors = @legislation.laws_sectors.order(:name)
        @keywords = @legislation.keywords.order(:name)
        @responses = @legislation.responses.order(:name)
        legislation_events = @legislation.events.order(:date)
        @legislation_events_with_links = legislation_events.map do |e|
          ::Api::Presenters::Event.call(e, :legislation)

          @admin_panel_section_title = "Climate Laws and Policies - #{@geography.name} - #{@legislation.title}"
          @link = admin_legislation_path(@legislation)
        end
      end

      private

      def set_common_breadcrumb
        if show_laws?
          add_breadcrumb('Laws', cclow_geography_laws_path(@geography))
        else
          add_breadcrumb('Policies', cclow_geography_policies_path(@geography))
        end
      end

      def show_laws?
        params[:scope] == :laws
      end
    end
  end
end
