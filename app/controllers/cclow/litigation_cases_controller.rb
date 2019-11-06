module CCLOW
  class LitigationCasesController < CCLOWController
    def index
      @litigations = Litigation.first(5)
    end
  end
end
