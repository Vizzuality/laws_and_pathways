module CCLOW
  module Api
    class TargetsController < CCLOWController
      def index
        # in framework climate laws or policies;
        # in sectoral laws or policies
        results = ::Geography.order(:name).find_each.map do |g|
          [g.iso, {
            in_framework: g.targets.joins(legislations: :tags)
              .where(tags: {type: 'Framework'}).any?,
            in_sectoral: g.targets.joins(legislations: :laws_sectors).any?
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

      def economy_wide_countries
        geographies = ::Geography.joins(targets: [:sector, :tags])
          .where.not(targets: {source: 'ndc'})
          .where(laws_sectors: {name: 'Economy-wide'})
          .where(tags: {type: 'Scope', name: 'Economy Wide'})
          .where(geography_type: 'national')
          .distinct
          .count
        render json: {total_parties: geographies}
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
