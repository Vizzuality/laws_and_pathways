module CSVExport
  module User
    module Helpers
      private

      def format_events(events)
        return unless events.any?

        # use sort_by instead of order to use cached by 'includes' events
        events.sort_by(&:date).map do |event|
          event
            .slice(:date, :title, :description, :url)
            .values
            .compact
            .join('|')
        end.join(';')
      end

      def format_documents(documents)
        return unless documents.any?

        documents.sort_by(&:created_at).map do |document|
          [document.name, document.url, document.language].join('|')
        end.join(';')
      end

      def format_sectors(sectors)
        sectors.map(&:name).sort.join(';')
      end

      def format_boolean(value)
        return if value.nil?

        value ? 'Yes' : 'No'
      end

      def strip_outer_div(content)
        content.gsub(/\A<div>(.*)<\/div>\z/su, '\1').strip
      end
    end
  end
end
