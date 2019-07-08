class ImportCPBenchmarks
  include ClimateWatchEngine::CSVImporter

  FILEPATH = "#{FILES_PREFIX}cpbenchmarks.csv".freeze

  def call
    ActiveRecord::Base.transaction do
      cleanup
      import
    end
  end

  private

  def import
    import_each_with_logging(csv, FILEPATH) do |row|
      sector = Sector.find_by!(name: row[:sector])
      benchmark = CP::Benchmark.find_or_initialize_by(
        sector: sector,
        date: parse_date(row[:date])
      )
      benchmarks = benchmark.benchmarks || []
      benchmarks << benchmark_attributes(row)
      benchmark.update!(
        benchmarks: benchmarks
      )
    end
  end

  def csv
    @csv ||= S3CSVReader.read(FILEPATH)
  end

  def cleanup
    CP::Benchmark.delete_all
  end

  def benchmark_attributes(row)
    {
      name: row[:type],
      values: values(row)
    }
  end

  def parse_date(date)
    Date.strptime(date, '%m-%Y')
  end

  def values(row)
    row.headers.grep(/\d{4}/).map do |year|
      {year: year.to_s.to_i, value: row[year]&.to_f}
    end
  end
end
