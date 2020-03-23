module CSVExport
  module User
    class Litigations
      include Helpers

      def initialize(litigation_ids)
        @ids = litigation_ids
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def call
        return if litigations.empty?

        headers = [
          'Title', 'Geography', 'Geography ISO', 'Jurisdiction',
          'Citation Reference Number', 'Responses', 'At issue',
          'Connected Internal Laws', 'Connected External Laws', 'Sectors',
          'Side A', 'Side B', 'Side C', 'Events', 'Summary'
        ]

        CSV.generate do |csv|
          csv << headers

          litigations.each do |litigation|
            csv << [
              litigation.title,
              litigation.geography_name,
              litigation.geography_iso,
              litigation.jurisdiction,
              litigation.citation_reference_number,
              litigation.responses_string,
              litigation.at_issue,
              format_laws(litigation.legislations),
              format_laws(litigation.external_legislations),
              format_sectors(litigation.laws_sectors),
              format_sides('a', litigation),
              format_sides('b', litigation),
              format_sides('c', litigation),
              format_events(litigation.events),
              litigation.summary
            ]
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      private

      def litigations
        Litigation
          .select(
            :id,
            :title,
            :jurisdiction,
            :citation_reference_number,
            :at_issue,
            :summary,
            'geographies.name as geography_name',
            'geographies.iso as geography_iso'
          )
          .left_outer_joins(:geography)
          .includes(
            :responses, :events, :legislations, :external_legislations,
            :laws_sectors, :litigation_sides
          )
          .where(id: @ids)
          .order('geography_name')
      end

      def format_laws(laws)
        laws.map do |law|
          [law.title, law.url].join('|')
        end.join(';')
      end

      def format_sides(side_type, litigation)
        litigation
          .litigation_sides
          .select { |s| s.side_type == side_type }
          .map { |s| [s.name, s.party_type].join('|') }
          .join(';')
      end
    end
  end
end
