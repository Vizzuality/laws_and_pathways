module CCLOW
  class ClimateTargetsController < CCLOWController
    include SearchController

    def index
      add_breadcrumb('Climate Targets', cclow_climate_targets_path)
      @climate_targets = if params[:ids]
                           ids = params[:ids].split(',').map(&:to_i)
                           add_breadcrumb('Search results', request.path)
                           Target.find(ids)
                         else
                           Target.all
                         end
      @climate_targets = CCLOW::TargetDecorator.decorate_collection(@climate_targets)
    end
  end
end
