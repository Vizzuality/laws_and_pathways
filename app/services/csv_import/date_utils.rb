module CSVImport
  class DateUtils
    class << self
      TWO_DIGIT_YEAR_CUTOFF = 2040

      def safe_parse(date, expected_date_formats)
        expected_date_formats.map { |format| parse_date(date, format) }.compact.first
      end

      def parse_date(date_text, format)
        date = Date.strptime(date_text, format)
        return date.prev_year(100) if two_digit_year?(format) && date.year > TWO_DIGIT_YEAR_CUTOFF

        date
      rescue ArgumentError
        nil
      end

      def two_digit_year?(format)
        format.include?('%y')
      end
    end
  end
end
