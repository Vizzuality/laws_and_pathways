module Api
  module ASCOR
    class BenchmarksChart
      attr_accessor :assessment_date, :country_id

      def initialize(assessment_date, country_id)
        @assessment_date = assessment_date
        @country_id = country_id
      end

      def call
        {data: collect_data, metadata: collect_metadata}
      end

      private

      def collect_data
        {
          emissions: pathway&.emissions || {},
          last_historical_year: pathway&.last_historical_year,
          benchmarks: benchmarks.map do |benchmark|
            {benchmark_type: benchmark.benchmark_type, emissions: benchmark.emissions}
          end
        }
      end

      def collect_metadata
        {unit: benchmarks.first&.units}
      end

      def pathway
        @pathway ||= ::ASCOR::Pathway.where(
          country_id: country_id,
          emissions_metric: benchmarks.first&.emissions_metric,
          emissions_boundary: benchmarks.first&.emissions_boundary,
          assessment_date: assessment_date
        ).first
      end

      def benchmarks
        @benchmarks ||= ::ASCOR::Benchmark.where(country_id: country_id)
      end
    end
  end
end
