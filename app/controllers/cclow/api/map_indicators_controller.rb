module CCLOW
  module Api
    class MapIndicatorsController < CCLOWController
      def index
        render json: {
          content: CCLOWMapContentData.all,
          context: CCLOWMapContextData.all,
          geographies: fetch_geographies
        }
      end

      private

      def fetch_geographies
        ::Geography.published.select(:id, :iso, :slug, :name).as_json.map do |g|
          g.merge(link: cclow_geography_path(g['id']))
        end
      end
    end
  end
end
