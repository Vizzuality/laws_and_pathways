module CCLOW
  class ClimateTargetsController < CCLOWController
    def index 
      if (params[:ids])
        ids = params[:ids].split(',').map(&:to_i)
        @targets = Target.find(ids)
      else
        @targets = Target.all
      end
    end
  end
end
