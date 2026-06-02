module CSVExport
  module User
    class CPBenchmarks
      def initialize(cp_benchmarks)
        @cp_benchmarks = cp_benchmarks
      end

      def call
        benchmarks = filtered_benchmarks
        year_columns = benchmarks.flat_map(&:emissions_all_years).uniq.sort
        headers = [
          'Benchmark ID', 'Benchmark Label', 'Sector name', 'Sub-sector',
          'Scenario name', 'Region', 'Release date', 'Unit'
        ].concat(year_columns)

        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          benchmarks.each do |benchmark|
            csv << [
              benchmark.benchmark_id,
              benchmark.benchmark_label,
              benchmark.sector&.name,
              benchmark.subsector,
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

      private

      CHEMICALS_SUBSECTOR_LABELS_DOWNCASED = CP::Benchmark::CHEMICALS_SUBSECTOR_LABELS.map(&:downcase).freeze

      def filtered_benchmarks
        @cp_benchmarks.reject do |b|
          b.sector&.name == 'Chemicals' &&
            b.subsector.present? &&
            !CHEMICALS_SUBSECTOR_LABELS_DOWNCASED.include?(b.subsector.downcase)
        end
      end
    end
  end
end
