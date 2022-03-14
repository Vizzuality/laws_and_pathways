module CSVExport
  module User
    class Legislations
      include Helpers

      def initialize(legislation_ids)
        @ids = legislation_ids
      end

      def call
        headers = [
          'Id', 'Title', 'Type', 'Geography', 'Geography ISO', 'Frameworks', 'Responses',
          'Instruments', 'Document Types', 'Natural Hazards', 'Keywords',
          'Sectors', 'Events', 'Documents', 'Parent Legislation', 'Description'
        ]

        Enumerator.new do |csv|
          csv << bom
          csv << CSV.generate_line(headers)

          legislations.each do |legislation|
            csv << CSV.generate_line(
              [
                legislation.id,
                legislation.title,
                legislation.legislation_type.downcase,
                legislation.geography_name,
                legislation.geography_iso,
                legislation.frameworks_csv,
                legislation.responses_csv,
                format_instruments(legislation.instruments),
                legislation.document_types_csv,
                legislation.natural_hazards_csv,
                legislation.keywords_csv,
                format_sectors(legislation.laws_sectors),
                format_events(legislation.events),
                format_documents(legislation.documents),
                legislation.parent&.title,
                legislation.description
              ]
            )
          end
        end
      end

      private

      def legislations
        Legislation
          .select(
            :id,
            :title,
            :legislation_type,
            :parent_id,
            :description,
            'geographies.name as geography_name',
            'geographies.iso as geography_iso'
          )
          .left_outer_joins(:geography)
          .includes(
            :laws_sectors, :instruments,
            :frameworks, :document_types, :keywords,
            :natural_hazards, :responses,
            :parent, :events,
            documents: {file_attachment: :blob}
          )
          .where(id: @ids)
          .order('geography_name, id')
      end

      def format_instruments(instruments)
        instruments.sort_by(&:created_at).map do |instrument|
          [instrument.name, instrument.instrument_type.name].join('|')
        end.join(';')
      end
    end
  end
end
