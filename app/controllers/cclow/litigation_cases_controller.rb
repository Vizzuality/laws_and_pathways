module CCLOW
  class LitigationCasesController < CCLOWController
    include SearchController
    
    def index
      if (params[:ids])
        ids = params[:ids].split(',').map(&:to_i)
        @litigations = Litigation.find(ids)
      else
        @litigations = Litigation.all
      end
    end
  end
end
