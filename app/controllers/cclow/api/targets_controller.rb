module CCLOW
  module Api
    class TargetsController < CCLOWController
      def index
        geography = ::Geography.find_by(iso: params[:iso])
        if geography
          render json: targets_as_json(geography)
        else
          render json: {error: 'not-found'}.to_json, status: 404
        end
      end

      private

      def targets_as_json(geography)
        result = {}
        result[:targets] = geography.targets.order(:year).map(&:to_api_format)
        result[:sectors] = LawsSector.order(:name).map do |s|
          {
            key: s.name.parameterize,
            title: s.name
          }
        end

        result[:country_meta] = {
          'BRA': {
            country_profile: cclow_geography_url(geography),
            lnp_count: geography.legislations.count
          }
        }
        result
      end

      def legislation_route(geography, legislation)
        send("cclow_geography_#{legislation.law? ? 'law' : 'policy'}_url",
             geography, legislation)
      end
    end
  end
end
