module CSVExport
  module User
    class CPBenchmarks
      def initialize(cp_benchmarks)
        @cp_benchmarks = cp_benchmarks
      end

      def call
        year_columns = @cp_benchmarks.flat_map(&:emissions_all_years).uniq.sort
        headers = ['Sector name', 'Scenario name', 'Release date', 'Unit'].concat(year_columns)

        CSV.generate do |csv|
          csv << headers

          @cp_benchmarks.each do |benchmark|
            csv << [
              benchmark.sector.name,
              benchmark.scenario,
              benchmark.release_date,
              benchmark.unit,
              year_columns.map do |year|
                benchmark.emissions[year]
              end
            ].flatten
          end
        end
      end
    end
  end
end
