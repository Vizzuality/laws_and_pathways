module CCLOW
  class ClimateTargetsController < CCLOWController
    include SearchController

    def index
      add_breadcrumb('Climate Targets', cclow_climate_targets_path)
      if params[:ids]
        ids = params[:ids].split(',').map(&:to_i)
        @climate_targets = Target.find(ids)
        add_breadcrumb('Search results', request.path)
      else
        @climate_targets = Target.all
      end
    end
  end
end
