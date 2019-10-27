module CCLOW
  class ClimateTargetsController < CCLOWController
    include GeographyController

    def index
      add_breadcrumb('Climate targets', request.path)
      @targets = @geography.targets
    end

    def show
      @target = Target.find(params[:id])
      add_breadcrumb('Climate targets', cclow_geography_climate_targets_path(@geography))
      add_breadcrumb(target.id, request.path)
    end
  end
end
