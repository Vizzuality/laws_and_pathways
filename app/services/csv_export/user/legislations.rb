module CSVExport
  module User
    class Legislations
      include Helpers

      def initialize(legislations)
        @legislations = legislations
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def call
        return if @legislations.empty?

        headers = [
          'Title', 'Type', 'Geography', 'Geography ISO', 'Frameworks', 'Responses',
          'Instruments', 'Document Types', 'Natural Hazards', 'Keywords',
          'Sectors', 'Events', 'Documents', 'Parent Legislation', 'Description'
        ]

        CSV.generate do |csv|
          csv << headers

          # TODO: Fix rails urls wihtout base path
          @legislations.each do |legislation|
            csv << [
              legislation.title,
              legislation.legislation_type.downcase,
              legislation.geography.name,
              legislation.geography.iso,
              legislation.frameworks_string,
              legislation.responses_string,
              format_instruments(legislation.instruments),
              legislation.document_types_string,
              legislation.natural_hazards_string,
              legislation.keywords_string,
              format_sectors(legislation.laws_sectors),
              format_events(legislation.events),
              format_documents(legislation.documents),
              legislation.parent&.title,
              legislation.description
            ]
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      private

      def format_instruments(instruments)
        instruments.map do |instrument|
          [instrument.name, instrument.instrument_type.name].join('|')
        end.join(';')
      end

      def format_sectors(sectors)
        sectors.map(&:name).join(';')
      end
    end
  end
end
