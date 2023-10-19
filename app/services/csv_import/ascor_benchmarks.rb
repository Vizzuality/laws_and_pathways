module CSVImport
  class ASCORBenchmarks < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        benchmark = prepare_benchmark(row)

        benchmark.country = countries[row[:country]].first if row.header?(:country)
        benchmark.publication_date = parse_date(row[:publication_date]) if row.header?(:publication_date)
        benchmark.emissions_metric = row[:emissions_metric] if row.header?(:emissions_metric)
        benchmark.emissions_boundary = row[:emissions_boundary] if row.header?(:emissions_boundary)
        benchmark.units = row[:units] if row.header?(:units)
        benchmark.benchmark_type = row[:benchmark_type] if row.header?(:benchmark_type)
        benchmark.emissions = parse_emissions(row, thousands_separator: ',') if emission_headers?(row)

        was_new_record = benchmark.new_record?
        any_changes = benchmark.changed?

        benchmark.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      ASCOR::Benchmark
    end

    def required_headers
      [:id]
    end

    def prepare_benchmark(row)
      find_record_by(:id, row) ||
        ASCOR::Benchmark.find_or_initialize_by(
          country: countries[row[:country]].first,
          emissions_metric: row[:emissions_metric],
          emissions_boundary: row[:emissions_boundary],
          benchmark_type: row[:benchmark_type]
        )
    end

    def countries
      @countries ||= ASCOR::Country.all.group_by(&:name)
    end

    def parse_date(date)
      CSVImport::DateUtils.safe_parse!(date, ['%Y-%m', '%Y-%m-%d'])
    end
  end
end
