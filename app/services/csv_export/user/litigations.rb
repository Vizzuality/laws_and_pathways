module CSVExport
  module User
    class Litigations
      include Helpers

      def initialize(litigations)
        @litigations = litigations
      end

      def call
        return if @litigations.empty?

        headers = ['Title', 'Document Type', 'Geography', 'Geography ISO',
                   'Jurisdiction', 'Citation Reference Number', 'Summary',
                   'Responses', 'Keywords', 'At issue', 'Connected Laws and Policies']

        CSV.generate do |csv|
          csv << headers

          @litigations.each do |litigation|
            csv << [
              litigation.title,
              litigation.document_type,
              litigation.geography&.name,
              litigation.geography&.iso,
              litigation.jurisdiction,
              litigation.citation_reference_number,
              litigation.summary,
              litigation.responses_string,
              litigation.keywords_string,
              litigation.at_issue,
              format_connected_laws(litigation)
            ]
          end
        end
      end

      private

      def format_connected_laws(litigation)
        [
          litigation.legislations.map(&:title),
          litigation.external_legislations.map(&:name)
        ].flatten.join(' | ')
      end
    end
  end
end
