module CSVImport
  class CompanyCPAssessments < CPAssessments
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        assessment = subsector?(row) ? prepare_assessment_subsector(row) : prepare_assessment(row)

        assessment.assessment_date = assessment_date(row) if row.header?(:assessment_date)
        assessment.assessment_date_flag = row[:assessment_date_flag] if row.header?(:assessment_date_flag)
        assessment.publication_date = publication_date(row) if row.header?(:publication_date)
        assessment.assumptions = row[:assumptions].presence if row.header?(:assumptions)
        assessment.emissions = parse_emissions(row) if emission_headers?(row)
        assessment.last_reported_year = row[:last_reported_year] if row.header?(:last_reported_year)
        assessment.cp_alignment_2025 = CP::Alignment.format_name(row[:cp_alignment_2025]) if row.header?(:cp_alignment_2025)
        assessment.cp_alignment_2027 = CP::Alignment.format_name(row[:cp_alignment_2027]) if row.header?(:cp_alignment_2027)
        assessment.cp_alignment_2028 = CP::Alignment.format_name(row[:cp_alignment_2028]) if row.header?(:cp_alignment_2028)
        assessment.cp_alignment_2035 = CP::Alignment.format_name(row[:cp_alignment_2035]) if row.header?(:cp_alignment_2035)
        assessment.cp_alignment_2050 = CP::Alignment.format_name(row[:cp_alignment_2050]) if row.header?(:cp_alignment_2050)
        assessment.region = parse_cp_benchmark_region(row[:region]) if row.header?(:region)
        if row.header?(:cp_regional_alignment_2025)
          assessment.cp_regional_alignment_2025 = CP::Alignment.format_name(row[:cp_regional_alignment_2025])
        end
        if row.header?(:cp_regional_alignment_2027)
          assessment.cp_regional_alignment_2027 = CP::Alignment.format_name(row[:cp_regional_alignment_2027])
        end
        if row.header?(:cp_regional_alignment_2028)
          assessment.cp_regional_alignment_2028 = CP::Alignment.format_name(row[:cp_regional_alignment_2028])
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

    def subsector?(row)
      row.header?(:subsector) && !row[:subsector].nil? && !row[:subsector].empty?
    end

    def prepare_assessment(row)
      find_record_by(:id, row) ||
        CP::Assessment.find_or_initialize_by(
          cp_assessmentable_type: 'Company',
          cp_assessmentable_id: find_company!(row)&.id,
          assessment_date: assessment_date(row),
          assessment_date_flag: row.header?(:assessment_date_flag) ? row[:assessment_date_flag] : nil
        )
    end

    def prepare_assessment_subsector(row)
      company_id = find_company!(row)&.id
      subsector = CompanySubsector.where(company_id: company_id, subsector: row[:subsector]).first

      # fallthru in case the subsector passed doesn't exist
      return prepare_assessment(row) unless subsector

      find_record_by(:id, row) ||
        CP::Assessment.find_or_initialize_by(
          cp_assessmentable_type: 'Company',
          cp_assessmentable_id: company_id,
          company_subsector_id: subsector.id,
          assessment_date: assessment_date(row),
          assessment_date_flag: row.header?(:assessment_date_flag) ? row[:assessment_date_flag] : nil
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
  end
end
