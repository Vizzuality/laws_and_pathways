module CSVExport
  module ASCOR
    class Benchmarks
      HEADERS = [
        'Id',
        'Country',
        'Publication date',
        'Emissions metric',
        'Emissions boundary',
        'Units',
        'Benchmark type'
      ].freeze

      def call
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << (HEADERS + year_columns)

          benchmarks.each do |benchmark|
            csv << [
              benchmark.id,
              benchmark.country.name,
              benchmark.publication_date,
              benchmark.emissions_metric,
              benchmark.emissions_boundary,
              benchmark.units,
              benchmark.benchmark_type,
              year_columns.map do |year|
                benchmark.emissions[year]
              end
            ].flatten
          end
        end
      end

      private

      def year_columns
        @year_columns ||= benchmarks.flat_map(&:emissions_all_years).uniq.sort
      end

      def benchmarks
        @benchmarks ||= ::ASCOR::Benchmark.joins(:country).includes(:country).order('ascor_countries.name')
      end
    end
  end
end
