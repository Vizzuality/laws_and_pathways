module CCLOW
  module Api
    class MapIndicatorsController < CCLOWController
      def index
        render json: {
          content: CCLOWMapContentData.all,
          context: CCLOWMapContextData.all
        }
      end
    end
  end
end
