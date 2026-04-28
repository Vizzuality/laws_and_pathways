module CSVExport
  module User
    class ChemicalsCPBenchmarks
      def initialize(cp_benchmarks)
        @cp_benchmarks = cp_benchmarks.select { |b| b.sector&.name == 'Chemicals' }
      end

      def call
        return nil if @cp_benchmarks.empty?

        year_columns = @cp_benchmarks.flat_map(&:emissions_all_years).uniq.sort
        headers = [
          'Benchmark ID', 'Benchmark Label', 'Sector name',
          'Scenario name', 'Region', 'Release date', 'Unit'
        ].concat(year_columns)

        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          @cp_benchmarks.each do |benchmark|
            csv << [
              benchmark.benchmark_id,
              benchmark.benchmark_label,
              benchmark.sector&.name,
              benchmark.scenario,
              benchmark.region,
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
