module CSVImport
  module Helpers
    module Emissions
      EMISSION_YEAR_PATTERN = /\d{4}/.freeze

      def parse_emissions(row)
        row.headers.grep(EMISSION_YEAR_PATTERN).reduce({}) do |acc, year|
          next acc unless row[year].present?

          acc.merge(year.to_s.to_i => row[year].to_f)
        end
      end
    end
  end
end
