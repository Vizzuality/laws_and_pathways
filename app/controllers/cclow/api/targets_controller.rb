module CCLOW
  module Api
    class TargetsController < CCLOWController
      def index
        results = ::Geography.order(:name).find_each.map do |g|
          [g.iso, {
            in_laws: g.targets.joins(:legislations)
              .where(legislations: {legislation_type: 'legislative'}).any?,
            in_policies: g.targets.joins(:legislations)
              .where(legislations: {legislation_type: 'executive'}).any?
          }]
        end.to_h
        render json: results
      end

      def show
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
          "#{geography.iso}": {
            country_profile: cclow_geography_url(geography),
            lnp_count: geography.legislations.count
          }
        }
        result
      end
    end
  end
end
