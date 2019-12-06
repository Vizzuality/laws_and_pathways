module CCLOW
  module Api
    class MapIndicatorsController < CCLOWController
      def index
        render json: {
          content: [],
          context: CCLOWMapData.all_data
        }
      end
    end
  end
end
