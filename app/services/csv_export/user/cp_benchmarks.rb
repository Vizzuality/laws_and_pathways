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
        @cp_benchmarks.select { |b| include_in_sector_benchmarks_export?(b) }
      end

      def include_in_sector_benchmarks_export?(benchmark)
        return true unless benchmark.sector&.name == 'Chemicals'

        chemicals_subsector_keys(benchmark).any? do |key|
          CHEMICALS_SUBSECTOR_LABELS_DOWNCASED.include?(key)
        end
      end

      def chemicals_subsector_keys(benchmark)
        [benchmark.subsector, benchmark.benchmark_label].compact.map { |v| v.strip.downcase }.uniq
      end
    end
  end
end
