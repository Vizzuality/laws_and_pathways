module CCLOW
  class LitigationCasesController < CCLOWController
    include GeographyController

    def index
      @litigations = @geography.litigations
    end

    def show
      @litigation = Litigation.find(params[:id])
    end
  end
end
