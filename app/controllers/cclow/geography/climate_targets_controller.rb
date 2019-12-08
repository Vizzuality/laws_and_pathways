module CCLOW
  module Geography
    class ClimateTargetsController < CCLOWController
      include GeographyController
      include SearchController

      def index
        add_breadcrumb('Climate targets', request.path)
        @climate_targets = @geography.targets
      end

      def show
        @target = ::Target.find(params[:id])
        add_breadcrumb('Climate targets', cclow_geography_climate_targets_path(@geography))
        add_breadcrumb(target.id, request.path)
      end
    end
  end
end
