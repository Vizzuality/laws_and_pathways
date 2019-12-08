module CSVImport
  class BaseImporter
    include ActiveModel::Model

    attr_reader :file, :import_results
    attr_accessor :override_id

    # @param file [File]
    # @param options [Hash]
    # @option override_id [Boolean] override automatic ids and make use of id in the import data
    def initialize(file, options = {})
      @file = file
      @override_id = options[:override_id] if options[:override_id]
    end

    def call
      return false unless csv

      reset_import_results
      import_results[:rows] = csv.count

      ActiveRecord::Base.transaction(requires_new: true) do
        import
        reset_id_seq if override_id
        # raise ActiveRecord::Rollback if errors.any?
      end

      errors.empty?
    end

    def import
      raise NotImplementedError
    end

    def resource_klass
      raise NotImplementedError
    end

    def csv
      @csv ||= parse_csv
    end

    def find_record_by(attr_name, row)
      resource_klass.find_by(attr_name.to_sym => row[attr_name]&.strip)
    end

    def prepare_overridden_resource(row)
      resource_klass.new do |r|
        r.id = row[:id]
      end
    end

    protected

    def header_converters
      [:symbol]
    end

    def csv_converters
      hard_space_converter = ->(f) { f&.gsub(160.chr('UTF-8'), 32.chr) }
      strip_converter = ->(field, _) { field&.strip }

      [hard_space_converter, strip_converter]
    end

    private

    def reset_id_seq
      table_name = resource_klass.table_name
      seq_name = "#{table_name}_id_seq"
      ActiveRecord::Base.connection
        .execute("select setval('#{seq_name}', max(id)) from #{table_name};")
    end

    def reset_import_results
      @import_results = {
        new_records: 0,
        updated_records: 0,
        not_changed_records: 0,
        rows: 0
      }
    end

    def parse_csv
      CSV.parse(
        encoded_file_content,
        headers: true,
        skip_blanks: true,
        converters: csv_converters,
        header_converters: header_converters
      ).delete_if { |row| row.to_hash.values.all?(&:blank?) }
    rescue CSV::MalformedCSVError => e
      errors.add(:base, e)
      false
    end

    def encoded_file_content
      File.read(file).force_encoding('UTF-8')
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
    rescue ActiveRecord::RecordInvalid => e
      handle_row_error(row_index, e, "for data: #{e.record.attributes}")
    rescue ActiveRecord::RecordNotFound, ArgumentError => e
      handle_row_error(row_index, e)
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

    def handle_row_error(row_index, exception, context_message = nil)
      readable_error_message = "Error on row #{row_index}: #{exception.message}."

      # log error with more details
      warn "[#{self.class.name}] #{readable_error_message} #{context_message}"

      # add import error
      errors.add(:base, :invalid_row, message: readable_error_message, row: row_index)
    end
  end
end
