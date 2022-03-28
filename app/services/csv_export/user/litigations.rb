module CSVExport
  module User
    class Litigations
      include Helpers

      def initialize(litigation_ids)
        @ids = litigation_ids
      end

      def call
        headers = [
          'Id', 'Title', 'Geography', 'Geography ISO', 'Jurisdiction',
          'Citation Reference Number', 'Responses', 'At issue',
          'Connected Internal Laws', 'Connected External Laws', 'Sectors',
          'Side A', 'Side B', 'Side C', 'Events', 'Summary'
        ]

        Enumerator.new do |csv|
          csv << bom
          csv << CSV.generate_line(headers)

          litigations.each do |litigation|
            csv << CSV.generate_line(
              [
                litigation.id,
                litigation.title,
                litigation.geography_name,
                litigation.geography_iso,
                litigation.jurisdiction,
                litigation.citation_reference_number,
                litigation.responses_csv,
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
            )
          end
        end
      end

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
          .order('geography_name, id')
      end

      def format_laws(laws)
        laws.sort_by(&:created_at).map do |law|
          [law.title, law.url].join('|')
        end.join(';')
      end

      def format_sides(side_type, litigation)
        litigation
          .litigation_sides
          .sort_by(&:created_at)
          .select { |s| s.side_type == side_type }
          .map { |s| [s.name, s.party_type].join('|') }
          .join(';')
      end
    end
  end
end
