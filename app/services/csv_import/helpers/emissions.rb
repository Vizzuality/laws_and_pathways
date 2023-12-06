module CSVImport
  module Helpers
    module Emissions
      EMISSION_YEAR_PATTERN = /^\d{4}$/.freeze

      def parse_emissions(row, thousands_separator: '')
        row.headers.grep(EMISSION_YEAR_PATTERN).reduce({}) do |acc, year|
          next acc if row[year].blank? || row[year] == 'NA'

          acc.merge(year.to_s.to_i => string_to_float(row[year], thousands_separator: thousands_separator))
        end
      end

      def emission_headers?(row)
        row.headers.grep(EMISSION_YEAR_PATTERN).any?
      end

      def string_to_float(string, thousands_separator: ',', ignored_texts: [])
        return string if ignored_texts.include?(string.downcase)
        return nil if string.blank?
        return string.to_f unless string.is_a?(String)

        string.delete(thousands_separator).delete("\t").delete(' ').to_f
      end
    end
  end
end
