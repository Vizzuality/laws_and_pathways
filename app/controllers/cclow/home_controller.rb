module CCLOW
  class HomeController < CCLOWController
    def index
      @latest_additions = Api::LatestAdditions.new(5).call
    end
  end
end
