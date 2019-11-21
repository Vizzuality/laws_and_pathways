module CCLOW
  class ClimateTargetsController < CCLOWController
    include SearchController

    def index
      if params[:ids]
        ids = params[:ids].split(',').map(&:to_i)
        @climate_targets = Target.find(ids)
      else
        @climate_targets = Target.all
      end
    end
  end
end
