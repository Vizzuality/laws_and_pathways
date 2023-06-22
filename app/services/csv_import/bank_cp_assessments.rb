module CSVImport
  class BankCPAssessments < CPAssessments
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        assessment = prepare_assessment(row)

        assessment.assessment_date = assessment_date(row) if row.header?(:assessment_date)
        assessment.publication_date = publication_date(row) if row.header?(:publication_date)
        assessment.assumptions = row[:assumptions].presence if row.header?(:assumptions)
        assessment.emissions = parse_emissions(row) if emission_headers?(row)
        assessment.last_reported_year = row[:last_reported_year] if row.header?(:last_reported_year)
        assessment.cp_alignment_2025 = CP::Alignment.format_name(row[:cp_alignment_2025]) if row.header?(:cp_alignment_2025)
        assessment.cp_alignment_2035 = CP::Alignment.format_name(row[:cp_alignment_2035]) if row.header?(:cp_alignment_2035)
        assessment.cp_alignment_2050 = CP::Alignment.format_name(row[:cp_alignment_2050]) if row.header?(:cp_alignment_2050)
        assessment.region = parse_cp_benchmark_region(row[:region]) if row.header?(:region)
        if row.header?(:cp_regional_alignment_2025)
          assessment.cp_regional_alignment_2025 = CP::Alignment.format_name(row[:cp_regional_alignment_2025])
        end
        if row.header?(:cp_regional_alignment_2035)
          assessment.cp_regional_alignment_2035 = CP::Alignment.format_name(row[:cp_regional_alignment_2035])
        end
        if row.header?(:cp_regional_alignment_2050)
          assessment.cp_regional_alignment_2050 = CP::Alignment.format_name(row[:cp_regional_alignment_2050])
        end
        assessment.years_with_targets = get_years_with_targets(row) if row.header?(:years_with_targets)

        was_new_record = assessment.new_record?
        any_changes = assessment.changed?

        assessment.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def prepare_assessment(row)
      find_record_by(:id, row) ||
        CP::Assessment.find_or_initialize_by(
          cp_assessmentable_type: 'Bank',
          cp_assessmentable_id: find_bank!(row)&.id,
          assessment_date: assessment_date(row),
          sector: find_or_create_tpi_sector(row[:sector], categories: [Bank])
        )
    end

    def find_bank!(row)
      return unless row[:bank].present?

      Bank.find_by!('LOWER(TRIM(name)) = ?', row[:bank].strip.downcase)
    end
  end
end
