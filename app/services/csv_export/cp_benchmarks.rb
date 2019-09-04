require 'csv'

module CSVExport
  class CPBenchmarks
    attr_reader :benchmarks

    def initialize(benchmarks)
      @benchmarks = benchmarks
    end

    def call
      year_columns = benchmarks.flat_map(&:benchmarks_all_years).uniq.sort

      headers = %w(Sector Date Name).concat(year_columns)

      CSV.generate do |csv|
        csv << headers

        benchmarks.each do |cp_benchmark|
          cp_benchmark.benchmarks.each do |benchmark|
            csv << [
              cp_benchmark.sector.name,
              cp_benchmark.date.strftime('%m-%Y'),
              benchmark['name'],
              year_columns.map { |yc| benchmark['values'][yc] }
            ].flatten
          end
        end
      end
    end
  end
end
