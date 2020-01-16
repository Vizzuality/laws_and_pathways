module CSVExport
  module User
    class Legislations
      include Helpers

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
              format_events(legislation.events)
            ]
          end
        end
      end
    end
  end
end
