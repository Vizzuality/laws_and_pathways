module CSVImport
  class BaseImporter
    include ActiveModel::Model

    DEFAULT_IMPORT_RESULTS = {
      new_records: 0,
      updated_records: 0,
      not_changed_records: 0,
      rows: 0
    }.freeze

    attr_reader :file, :import_results

    def initialize(file)
      @file = file
      @import_results ||= DEFAULT_IMPORT_RESULTS
    end

    def call
      return false unless parse_csv

      import_results[:rows] = csv.count

      ActiveRecord::Base.transaction(requires_new: true) do
        import
        raise ActiveRecord::Rollback if errors.any?
      end

      errors.empty?
    end

    def import
      raise NotImplementedError
    end

    private

    def csv
      @csv ||= parse_csv
    end

    def parse_csv
      CSV.parse(
        file,
        headers: true,
        skip_blanks: true,
        converters: csv_converters,
        header_converters: [:symbol]
      ).delete_if { |row| row.to_hash.values.all?(&:blank?) }
    rescue CSV::MalformedCSVError => e
      errors.add(:base, e)
      false
    end

    def csv_converters
      hard_space_converter = ->(f) { f&.gsub(160.chr('UTF-8'), 32.chr) }
      strip_converter = ->(field, _) { field&.strip }

      [hard_space_converter, strip_converter]
    end

    def import_each_csv_row(csv)
      csv.each.with_index(2) do |row, row_index|
        with_logging(row_index) do
          yield row
        end
      end
    end

    def with_logging(row_index)
      yield
    rescue ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound,
           ArgumentError => e
      msg = "Error importing row #{row_index}: #{e}"
      errors.add(:base, :invalid_row, message: msg, row: row_index)
    end

    def update_import_results(was_new_record, any_changes)
      if was_new_record
        import_results[:new_records] += 1
      elsif any_changes
        import_results[:updated_records] += 1
      else
        import_results[:not_changed_records] += 1
      end
    end
  end
end
