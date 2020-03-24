module CSVExport
  module User
    class Targets
      include Helpers

      def initialize(target_ids)
        @ids = target_ids
      end

      def call
        return if targets.empty?

        headers = ['Type', 'Description', 'Is GHG Target?', 'Year',
                   'Base Year Period', 'Is Single Year Target?', 'Source',
                   'Geography', 'Geography ISO', 'Sector', 'Scopes', 'Events']

        CSV.generate do |csv|
          csv << headers

          targets.each do |target|
            csv << [
              target.target_type,
              target.description,
              format_boolean(target.ghg_target),
              target.year,
              target.base_year_period,
              format_boolean(target.single_year),
              target.source,
              target.geography_name,
              target.geography_iso,
              target.sector&.name,
              target.scopes_string,
              format_events(target.events)
            ]
          end
        end
      end

      private

      def targets
        Target
          .select(
            :id,
            :target_type,
            :description,
            :ghg_target,
            :year,
            :base_year_period,
            :single_year,
            :source,
            :sector_id,
            'geographies.name as geography_name',
            'geographies.iso as geography_iso'
          )
          .left_outer_joins(:geography)
          .includes(:sector, :scopes, :events)
          .where(id: @ids)
          .order('geography_name, id')
      end
    end
  end
end
