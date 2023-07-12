module CSVImport
  class BankCPAssessments < CPAssessments
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        CP::Assessment.transaction do
          assessment = prepare_assessment(row)

          assessment.assessment_date = assessment_date(row) if row.header?(:assessment_date)
          assessment.publication_date = publication_date(row) if row.header?(:publication_date)
          assessment.sector = find_or_create_tpi_sector(row[:sector], categories: [Bank]) if row.header?(:sector)
          assessment.region = parse_cp_benchmark_region(row[:region]) if row.header?(:region)
          assessment.assumptions = row[:assumptions].presence if row.header?(:assumptions)
          assessment.emissions = parse_emissions(row) if emission_headers?(row)
          assessment.final_disclosure_year = row[:final_disclosure_year] if row.header?(:final_disclosure_year)
          assessment.years_with_targets = get_years_with_targets(row) if row.header?(:years_with_targets)

          was_new_record = assessment.new_record?
          any_changes = assessment.changed?

          assessment.save!
          update_cp_matrices_for! assessment, row

          update_import_results(was_new_record, any_changes)
        end
      end
    end

    private

    def alignment_key
      raise NotImplementedError
    end

    def update_cp_matrices_for!(assessment, row)
      CP::Portfolio::NAMES.each do |portfolio_name|
        key = CSV::HeaderConverters[header_converters.first].call portfolio_name
        next unless row.header? key

        cp_alignment = CP::Alignment.format_name(row[key])
        cp_matrix = assessment.cp_matrices.find_or_initialize_by(portfolio: portfolio_name)
        cp_matrix.public_send("#{alignment_key}=", cp_alignment)
        cp_matrix.save!
      end
    end

    def prepare_assessment(row)
      find_record_by(:id, row) ||
        CP::Assessment.find_or_initialize_by(
          cp_assessmentable_type: 'Bank',
          cp_assessmentable_id: find_bank!(row)&.id,
          assessment_date: assessment_date(row),
          sector: find_or_create_tpi_sector(row[:sector], categories: [Bank]),
          region: parse_cp_benchmark_region(row[:region])
        )
    end

    def find_bank!(row)
      return unless row[:bank_id].present?

      bank = Bank.find(row[:bank_id])
      if bank.name.strip.downcase != row[:bank].strip.downcase
        puts "!!WARNING!! CHECK YOUR FILE ID DOESN'T MATCH BANK NAME!! #{row[:bank_id]} #{row[:bank]}"
      end
      bank
    end
  end
end
