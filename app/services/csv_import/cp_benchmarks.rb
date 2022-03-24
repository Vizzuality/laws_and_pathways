module CSVImport
  class CPBenchmarks < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        benchmark = prepare_benchmark(row)

        benchmark.sector = find_or_create_tpi_sector(row[:sector]) if row.header?(:sector)
        benchmark.release_date = parse_date(row[:release_date]) if row.header?(:release_date)
        benchmark.scenario = row[:scenario] if row.header?(:scenario)
        benchmark.region = parse_cp_benchmark_region(row[:region]) if row.header?(:region)
        benchmark.emissions = parse_emissions(row) if emission_headers?(row)

        was_new_record = benchmark.new_record?
        any_changes = benchmark.changed?

        benchmark.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      CP::Benchmark
    end

    def required_headers
      [:id]
    end

    def prepare_benchmark(row)
      find_record_by(:id, row) ||
        CP::Benchmark.find_or_initialize_by(
          sector: find_or_create_tpi_sector(row[:sector]),
          release_date: parse_date(row[:release_date]),
          scenario: row[:scenario]
        )
    end

    def parse_date(date)
      CSVImport::DateUtils.safe_parse!(date, ['%Y-%m', '%Y-%m-%d'])
    end
  end
end
