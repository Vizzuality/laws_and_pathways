module CCLOW
  module Geography
    class LegislationsController < CCLOWController
      include GeographyController
      include SearchController

      before_action :set_common_breadcrumb

      def index
        @legislations = if show_laws?
                          @geography.legislations.laws
                        else
                          @geography.legislations.policies
                        end
        @legislations = @legislations.joins(:events).order('events.date DESC')
        @legislations = CCLOW::LegislationDecorator.decorate_collection(@legislations)
      end

      def show
        @legislation = CCLOW::LegislationDecorator.new(::Legislation.find(params[:id]))
        add_breadcrumb(@legislation.title, request.path)
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
