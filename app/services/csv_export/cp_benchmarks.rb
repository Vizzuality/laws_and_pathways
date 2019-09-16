require 'csv'

module CSVExport
  class CPBenchmarks
    attr_reader :benchmarks

    def initialize(benchmarks)
      @benchmarks = benchmarks
    end

    def call
      year_columns = benchmarks.flat_map(&:emissions_all_years).uniq.sort

      headers = ['Id', 'Sector', 'Release Date', 'Scenario'].concat(year_columns)

      CSV.generate do |csv|
        csv << headers

        benchmarks.latest_first.each do |benchmark|
          csv << [
            benchmark.id,
            benchmark.sector.name,
            benchmark.release_date.strftime('%m-%Y'),
            benchmark.scenario,
            year_columns.map { |yc| benchmark.emissions[yc] }
          ].flatten
        end
      end
    end
  end
end
