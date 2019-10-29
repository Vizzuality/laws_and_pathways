module CCLOW
  class LitigationCasesController < CCLOWController
    def index
      @litigations = Litigation.all
    end
  end
end
