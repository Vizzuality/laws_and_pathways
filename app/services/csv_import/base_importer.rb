require "#{Rails.root}/lib/unicode_fixer"

module CSVImport
  class BaseImporter
    include ActiveModel::Model

    attr_reader :file, :import_results
    attr_accessor :override_id, :rollback_on_error, :allow_tags_adding

    validate :check_if_current_user_authorized
    validate :check_required_headers

    # @param file [File]
    # @param options [Hash]
    # @option override_id [Boolean] override automatic ids and make use of id in the import data, default: false
    # @option rollback_on_error [Boolean] when true it rollbacks all changes when any row is not valid, default: false
    def initialize(file, options = {})
      @file = file
      @override_id = options.fetch(:override_id, false)
      @rollback_on_error = options.fetch(:rollback_on_error, false)
      @allow_tags_adding = options.fetch(:allow_tags_adding, false)
    end

    def call
      reset_import_results
      return false unless csv

      import_results[:rows] = csv.count

      return false unless valid?

      ActiveRecord::Base.transaction(requires_new: true) do
        perform_import
        reset_id_seq if override_id

        rollback if rollback_on_error && errors.any?
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

    def find_record_by(attr_name, row, column_name: nil)
      resource_klass.find_by(attr_name.to_sym => row[column_name || attr_name]&.strip)
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
      unicode_fixer = ->(field) { UnicodeFixer.fix_unicode_characters(field) }

      [hard_space_converter, strip_converter, unicode_fixer]
    end

    def required_headers
      []
    end

    def current_user
      ::Current.admin_user
    end

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
      File.read(file, encoding: 'bom|utf-8').force_encoding('UTF-8')
    end

    def import_each_csv_row(csv)
      csv.each.with_index(2) do |row, row_index|
        handle_row_errors(row_index) do
          yield Row.new(row)
        end
      end
    end

    def handle_row_errors(row_index)
      yield
    rescue ActiveRecord::RecordInvalid => e
      handle_row_error(row_index, e, "for data: #{e.record.attributes}")
    rescue ActiveRecord::RecordNotFound, ArgumentError, CSVImport::DateUtils::DateParseError => e
      handle_row_error(row_index, e)
    rescue CSVImport::MissingHeader
      raise
    rescue StandardError => e
      Appsignal.set_error(e)
      handle_row_error(row_index, e)
    end

    def handle_row_error(row_index, exception, context_message = nil)
      readable_error_message = "Error on row #{row_index - 1}: #{exception.message}."

      # log error with more details
      warn "[#{self.class.name}] #{readable_error_message} #{context_message}"

      # add import error
      errors.add(:base, :invalid_row, message: readable_error_message, row: row_index)
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

    private

    def perform_import
      import
    rescue CSVImport::MissingHeader => e
      warn e.message
      errors.add(:base, e.message)
    end

    def rollback
      import_results[:new_records] = 0
      import_results[:updated_records] = 0
      import_results[:not_changed_records] = 0

      raise ActiveRecord::Rollback
    end

    def check_if_current_user_authorized
      return unless current_user.present?
      return if current_user.can?(:create, resource_klass) && current_user.can?(:update, resource_klass)

      errors.add(:base, "User not authorized to import #{resource_klass}")
    end

    def check_required_headers
      (required_headers - csv.headers).each do |header|
        errors.add(:base, "CSV missing header: #{header.to_s.humanize(keep_id_suffix: true)}")
      end
    end
  end
end
