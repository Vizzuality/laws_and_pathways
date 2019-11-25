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
          assessment_date: assessment_date(row)
        )
    end

    def find_company!(row)
      return unless row[:company_id].present?

      Company.find(row[:company_id])
    end

    def assessment_attributes(row)
      {
        assessment_date: assessment_date(row),
        publication_date: publication_date(row),
        assumptions: row[:assumptions],
        emissions: parse_emissions(row),
        last_reported_year: row[:last_reported_year]
      }
    end

    def assessment_date(row)
      CSVImport::DateUtils.safe_parse(row[:assessment_date], ['%Y-%m-%d']) if row[:assessment_date]
    end

    def publication_date(row)
      CSVImport::DateUtils.safe_parse(row[:publication_date], ['%Y-%m'])
    end
  end
end
