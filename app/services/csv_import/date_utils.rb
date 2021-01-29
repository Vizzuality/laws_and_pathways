module CSVImport
  class DateUtils
    class << self
      TWO_DIGIT_YEAR_CUTOFF = 2040

      DateParseError = Class.new(StandardError)

      def safe_parse!(date, expected_date_formats)
        return if date.nil?

        safe_parse(date, expected_date_formats) or
          raise DateParseError, "Cannot parse date: #{date}, expected formats: #{expected_date_formats.join(', ')}"
      end

      def safe_parse(date, expected_date_formats)
        return if date.nil?

        expected_date_formats.map { |format| parse_date(date, format) }.compact.first
      end

      def parse_date(date_text, format)
        date = DateTime.strptime(date_text.strip, format).to_date
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
