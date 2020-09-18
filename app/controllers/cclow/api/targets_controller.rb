module CCLOW
  module Api
    class TargetsController < CCLOWController
      def index
        # in framework climate laws or policies;
        # in sectoral laws or policies
        results = ::Geography.order(:name).find_each.map do |g|
          [g.iso, {
            in_framework: g.targets.published.joins(:legislations)
              .where(legislations: {id: Legislation.framework.published}).any?,
            in_sectoral: g.targets.published.joins(:legislations)
              .where(legislations: {id: Legislation.sectoral.published}).any?
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
          .where(tags: {type: 'Scope', name: ['Economy Wide', 'Economy-Wide']})
          .where(geography_type: 'national')
          .distinct
          .pluck(:iso)
        render json: {countries: geographies, total_countries: geographies.size}
      end

      private

      def targets_as_json(geography)
        result = {}
        result[:targets] = geography.targets.published.order(:year).map(&:to_api_format)
        result[:sectors] = LawsSector.order(:name).map do |s|
          {
            key: s.name.parameterize,
            title: s.name
          }
        end

        result[:country_meta] = {
          "#{geography.iso}": {
            country_profile: cclow_geography_url(geography),
            lnp_count: geography.legislations.published.count
          }
        }
        result
      end
    end
  end
end
