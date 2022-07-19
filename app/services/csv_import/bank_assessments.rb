module CSVImport
  class BankAssessments < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        assessment = prepare_assessment(row)

        assessment.bank = find_bank(row) if row.header?(:bank)
        assessment.assessment_date = assessment_date(row) if row.header?(:assessment_date)

        was_new_record = assessment.new_record?
        # any_changes = assessment.changed?

        assessment.save!

        save_assessment_results(assessment, row)

        update_import_results(was_new_record, !was_new_record)
      end
    end

    private

    def header_converters
      converter = lambda { |header| header.squish.tr(' ', '_').downcase.underscore.to_sym }
      [converter]
    end

    def resource_klass
      BankAssessment
    end

    def required_headers
      [:id]
    end

    def prepare_assessment(row)
      return prepare_overridden_resource(row) if override_id

      find_record_by(:id, row) ||
        BankAssessment.find_or_initialize_by(
          bank: find_bank(row),
          assessment_date: assessment_date(row)
        )
    end

    def save_assessment_results(assessment, row)
      BankAssessmentResult.where(assessment: assessment).delete_all
      results = []
      BankAssessmentIndicator.find_each do |indicator|
        results << parse_assessment_result(assessment, indicator, row)
      end
      BankAssessmentResult.import! results
    end

    def parse_assessment_result(assessment, indicator, row)
      row_key = "#{indicator.indicator_type}_#{indicator.number}".to_sym
      result = BankAssessmentResult.new(assessment: assessment, indicator: indicator)
      result.percentage = row[row_key].to_i if indicator.percentage_indicator?
      result.answer = row[row_key] if indicator.answer_indicator?
      result
    end

    def find_bank(row)
      return Bank.find_by(name: row[:bank]) if row.header?(:bank) && row[:bank].present?

      nil
    end

    def assessment_date(row)
      CSVImport::DateUtils.safe_parse!(row[:assessment_date], ['%Y-%m-%d', '%d/%m/%Y'])
    end
  end
end
