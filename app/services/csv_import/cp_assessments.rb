module CSVImport
  class CPAssessments < BaseImporter
    include UploaderHelpers

    def import
      import_each_csv_row(csv) do |row|
        assessment = prepare_assessment(row)
        assessment.assign_attributes(assessment_attributes(row))

        was_new_record = assessment.new_record?
        any_changes = assessment.changed?

        assessment.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      CP::Assessment
    end

    def prepare_assessment(row)
      find_record_by(:id, row) ||
        CP::Assessment.find_or_initialize_by(
          company: find_company!(row),
          assessment_date: parse_date(row[:assessment_date])
        )
    end

    def find_company!(row)
      return unless row[:sector].present?

      Company.where('lower(name) = ?', row[:company].downcase).first!
    end

    def assessment_attributes(row)
      {
        assessment_date: parse_date(row[:assessment_date]),
        assumptions: row[:assumptions],
        emissions: parse_emissions(row)
      }
    end

    def parse_date(date)
      Import::DateUtils.safe_parse(date, ['%Y-%m', '%Y-%m-%d'])
    end
  end
end
