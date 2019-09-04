module CSVImport
  class CPBenchmarks < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        sector = find_or_create_sector(row)
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

    private

    def find_or_create_sector(row)
      return unless row[:sector].present?

      Sector.where('lower(name) = ?', row[:sector].downcase).first ||
        Sector.new(name: row[:sector])
    end

    def benchmark_attributes(row)
      {
        name: row[:type],
        values: values(row)
      }
    end

    def parse_date(date)
      Import::DateUtils.safe_parse(date, ['%m-%Y'])
    end

    def values(row)
      row.headers.grep(/\d{4}/).map do |year|
        {year.to_s.to_i => row[year]&.to_f}
      end.reduce(&:merge)
    end
  end
end
