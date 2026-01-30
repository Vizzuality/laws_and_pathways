module CSVImport
  class ASCORAssessmentIndicators < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        indicator = prepare_indicator(row)

        indicator.indicator_type = row[:type].downcase
        indicator.code = row[:code]
        indicator.text = row[:text]
        indicator.units_or_response_type = row[:units_or_response_type] if row.header?(:units_or_response_type)
        indicator.assessment_date = assessment_date(row) if row.header?(:assessment_date)

        was_new_record = indicator.new_record?
        any_changes = indicator.changed?

        indicator.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      ASCOR::AssessmentIndicator
    end

    def required_headers
      [:id, :code, :type, :text]
    end

    def prepare_indicator(row)
      find_record_by(:id, row) ||
        resource_klass.find_or_initialize_by(
          code: row[:code],
          indicator_type: row[:type],
          assessment_date: assessment_date(row)
        )
    end

    def assessment_date(row)
      CSVImport::DateUtils.safe_parse!(row[:assessment_date], ['%Y-%m-%d', '%m/%d/%y']) if row[:assessment_date]
    end
  end
end
