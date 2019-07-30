module Import
  class DateUtils
    class << self
      def safe_parse(date, expected_date_formats)
        expected_date_formats.map { |format| parse_date(date, format) }.compact.first
      end

      def parse_date(date, format)
        Date.strptime(date, format)
      rescue ArgumentError
        nil
      end
    end
  end
end
