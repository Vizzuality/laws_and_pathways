module CSVExport
  module User
    class Targets
      include Helpers

      def initialize(targets)
        @targets = targets
      end

      def call
        return if @targets.empty?

        headers = ['Type', 'Description', 'Is GHG Target?', 'Year',
                   'Base Year Period', 'Is Single Year Target?', 'Source',
                   'Geography', 'Geography ISO', 'Sector', 'Scopes', 'Events']

        CSV.generate do |csv|
          csv << headers

          @targets.each do |target|
            csv << [
              target.target_type,
              target.description,
              format_boolean(target.ghg_target),
              target.year,
              target.base_year_period,
              format_boolean(target.single_year),
              target.source,
              target.geography.name,
              target.geography.iso,
              target.sector&.name,
              target.scopes_string,
              format_events(target.events)
            ]
          end
        end
      end
    end
  end
end
