module CSVImport
  class CPAssessments < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        assessment = prepare_assessment(row)

        assessment.assessment_date = assessment_date(row) if row.header?(:assessment_date)
        assessment.publication_date = publication_date(row) if row.header?(:publication_date)
        assessment.assumptions = row[:assumptions].presence if row.header?(:assumptions)
        assessment.emissions = parse_emissions(row) if emission_headers?(row)
        assessment.last_reported_year = row[:last_reported_year] if row.header?(:last_reported_year)
        assessment.cp_alignment = CP::Alignment.format_name(row[:cp_alignment]) if row.header?(:cp_alignment)
        assessment.cp_alignment_year_override = row[:cp_alignment_year_override] if row.header?(:cp_alignment_year_override)

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

    def required_headers
      [:id]
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

      company = Company.find(row[:company_id])
      if company.name.strip.downcase != row[:company].strip.downcase
        puts "!!WARNING!! CHECK YOUR FILE ID DOESN'T MATCH COMPANY NAME!! #{row[:company_id]} #{row[:company]}"
      end
      company
    end

    def assessment_date(row)
      CSVImport::DateUtils.safe_parse!(row[:assessment_date], ['%Y-%m-%d', '%d/%m/%Y']) if row[:assessment_date]
    end

    def publication_date(row)
      CSVImport::DateUtils.safe_parse!(row[:publication_date], ['%Y-%m'])
    end
  end
end
