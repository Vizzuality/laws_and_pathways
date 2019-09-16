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
          sector: find_or_create_sector(row),
          release_date: parse_date(row[:release_date]),
          scenario: row[:scenario]
        )
    end

    def find_or_create_sector(row)
      return unless row[:sector].present?

      Sector.where('lower(name) = ?', row[:sector].downcase).first ||
        Sector.new(name: row[:sector])
    end

    def benchmark_attributes(row)
      {
        scenario: row[:scenario],
        release_date: parse_date(row[:release_date]),
        emissions: emissions(row)
      }
    end

    def parse_date(date)
      Import::DateUtils.safe_parse(date, ['%m-%Y'])
    end

    def emissions(row)
      row.headers.grep(/\d{4}/).map do |year|
        {year.to_s.to_i => row[year]&.to_f}
      end.reduce(&:merge)
    end
  end
end
