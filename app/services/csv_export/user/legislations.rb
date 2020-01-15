module CSVExport
  module User
    class Legislations
      def initialize(legislations)
        @legislations = legislations
      end

      def call
        return if @legislations.empty?

        headers = ['Title', 'Description', 'Type', 'Parent', 'Geography', 'Geography Code',
                   'Frameworks', 'Responses', 'Document Types', 'Keywords', 'Natural Hazards',
                   'Events']

        CSV.generate do |csv|
          csv << headers

          @legislations.each do |legislation|
            csv << [
              legislation.title,
              legislation.description,
              legislation.legislation_type.downcase,
              legislation.parent&.title,
              legislation.geography.name,
              legislation.geography.iso,
              legislation.frameworks_string,
              legislation.responses_string,
              legislation.document_types_string,
              legislation.keywords_string,
              legislation.natural_hazards_string,
              # use sort_by instead of order to use cached by 'includes' events
              format_events(legislation.events.sort_by(&:date))
            ].flatten
          end
        end
      end

      private

      def format_events(events)
        return unless events.any?

        events.map do |event|
          event
            .slice(:date, :title, :description, :url)
            .values
            .compact
            .join(' | ')
        end.join(' ; ')
      end
    end
  end
end
