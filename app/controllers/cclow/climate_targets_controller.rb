module CCLOW
  class ClimateTargetsController < CCLOWController
    include GeographyController

    def index
      @targets = @geography.targets
    end

    def show
      @target = Target.find(params[:id])
    end
  end
end
