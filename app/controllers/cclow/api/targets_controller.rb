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
        geography.targets.order(:year).map do |t|
          {
            id: t.id,
            iso_code3: geography.iso,
            doc_type: t.source&.humanize,
            type: t.target_type&.humanize,
            scope: t.scopes&.map(&:name)&.join(', '),
            sector: t.sector&.name,
            description: t.description,
            sources: t.legislations.map do |l|
              {
                id: l.id,
                title: l.title,
                link: legislation_route(geography, l)
              }
            end
          }
        end
      end

      def legislation_route(geography, legislation)
        send("cclow_geography_#{legislation.law? ? 'law' : 'policy'}_url",
             geography, legislation)
      end
    end
  end
end
