module CSVImport
  class CPBenchmarks < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        benchmark = prepare_benchmark(row)
        benchmark.assign_attributes(benchmark_attributes(row))

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

    def prepare_benchmark(row)
      find_record_by(:id, row) ||
        CP::Benchmark.find_or_initialize_by(
          sector: find_or_create_tpi_sector(row[:sector]),
          release_date: parse_date(row[:release_date]),
          scenario: row[:scenario]
        )
    end

    def benchmark_attributes(row)
      {
        scenario: row[:scenario],
        release_date: parse_date(row[:release_date]),
        emissions: parse_emissions(row)
      }
    end

    def parse_date(date)
      CSVImport::DateUtils.safe_parse!(date, ['%Y-%m', '%Y-%m-%d'])
    end
  end
end
