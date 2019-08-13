module Upload
  class BaseUploader
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def call
      ActiveRecord::Base.transaction(requires_new: true) do
        details[:rows] = csv.count
        import

        raise ActiveRecord::Rollback if errors.any?
      end

      errors.empty?
    end

    def import
      raise NotImplementedError
    end

    def errors
      @errors ||= []
    end

    def details
      @details ||= {
        inserted_records: 0,
        updated_records: 0,
        not_changed_records: 0
      }
    end

    private

    def csv
      return @csv if defined?(@csv)

      hard_space_converter = ->(f) { f&.gsub(160.chr('UTF-8'), 32.chr) }
      strip_converter = ->(field, _) { field&.strip }

      @csv = CSV.parse(
        file,
        headers: true,
        skip_blanks: true,
        converters: [hard_space_converter, strip_converter],
        header_converters: [:symbol]
      ).delete_if { |row| row.to_hash.values.all?(&:blank?) }
    end

    def add_error(type, details = {})
      msg = details.fetch(:msg, 'Error')
      errors << {type: type, msg: msg}.merge(details.except(:msg))
    end

    def import_each_with_logging(csv)
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
      add_error(:invalid_row, msg: msg, row: row_index)
    end

    def update_stats(was_new_record, any_changes)
      if was_new_record
        details[:inserted_records] += 1
      elsif any_changes
        details[:updated_records] += 1
      else
        details[:not_changed_records] += 1
      end
    end
  end
end
