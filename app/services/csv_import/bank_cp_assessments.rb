module CSVImport
  class BankCPAssessments < CPAssessments
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        CP::Assessment.transaction do
          normalized_sector, normalized_subsector = CP::SectorNormalizer.normalize(row[:sector], row[:subsector])
          raise ArgumentError, "Unknown sector '#{row[:sector]}'" if row.header?(:sector) && !normalized_sector.present?

          assessment = prepare_assessment(row)

          assessment.assessment_date = assessment_date(row) if row.header?(:assessment_date)
          assessment.publication_date = publication_date(row) if row.header?(:publication_date)
          assessment.sector = TPISector.find_by!(name: normalized_sector) if row.header?(:sector)
          assessment.region = parse_cp_benchmark_region(row[:region]) if row.header?(:region)
          assessment.assumptions = row[:assumptions].presence if row.header?(:assumptions)
          assessment.emissions = parse_emissions(row) if emission_headers?(row)
          assessment.final_disclosure_year = row[:final_disclosure_year] if row.header?(:final_disclosure_year)
          assessment.last_reported_year = row[:last_reported_year] if row.header?(:last_reported_year)
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

    def required_headers
      []
    end

    def header_converters
      custom = ->(field) { field == 'BankID' ? 'bank_id' : field }
      [custom, :symbol]
    end

    def alignment_key
      raise NotImplementedError
    end

    def update_cp_matrices_for!(assessment, row)
      CP::Portfolio::NAMES.each do |portfolio_name|
        header_keys = portfolio_header_keys_for(portfolio_name)
        key_in_row = header_keys.find { |k| row.header? k }
        next unless key_in_row

        cp_alignment = CP::Alignment.format_name(row[key_in_row])
        cp_matrix = assessment.cp_matrices.find_or_initialize_by(portfolio: portfolio_name)
        cp_matrix.public_send("#{alignment_key}=", cp_alignment)
        cp_matrix.save!
      end
    end

    def portfolio_header_keys_for(portfolio_name)
      base = CSV::HeaderConverters[:symbol].call(portfolio_name)
      with_year = CSV::HeaderConverters[:symbol].call("#{portfolio_name} #{alignment_year_str}")
      [base, with_year].uniq
    end

    def alignment_year_str
      alignment_key.to_s.split('_').last
    end

    def prepare_assessment(row)
      if row[:subsector].present?
        prepare_assessment_subsector(row)
      else
        prepare_assessment_general(row)
      end
    end

    def prepare_assessment_subsector(row)
      bank_id = find_bank!(row)&.id
      normalized_sector, normalized_subsector = CP::SectorNormalizer.normalize(row[:sector], row[:subsector])
      sector = TPISector.find_by!(name: normalized_sector)
      unless normalized_subsector.present?
        raise ArgumentError,
              "Unknown subsector '#{row[:subsector]}' for sector '#{normalized_sector}'"
      end

      subsector = Subsector.find_by!(sector: sector, name: normalized_subsector)

      find_record_by(:id, row) ||
        CP::Assessment.find_or_initialize_by(
          cp_assessmentable_type: 'Bank',
          cp_assessmentable_id: bank_id,
          subsector: subsector,
          assessment_date: assessment_date(row),
          sector: sector,
          region: parse_cp_benchmark_region(row[:region])
        )
    end

    def prepare_assessment_general(row)
      find_record_by(:id, row) ||
        CP::Assessment.find_or_initialize_by(
          cp_assessmentable_type: 'Bank',
          cp_assessmentable_id: find_bank!(row)&.id,
          assessment_date: assessment_date(row),
          sector: (if row.header?(:sector)
                     TPISector.find_by!(name: CP::SectorNormalizer.normalize(row[:sector],
                                                                             nil).first)
                   end),
          region: parse_cp_benchmark_region(row[:region])
        )
    end

    def find_bank!(row)
      if row[:bank_id].present?
        bank = Bank.find(row[:bank_id])
        if row.header?(:bank) && row[:bank].present? && (bank.name.strip.downcase != row[:bank].strip.downcase)
          puts "!!WARNING!! CHECK YOUR FILE ID DOESN'T MATCH BANK NAME!! #{row[:bank_id]} #{row[:bank]}"
        end
        return bank
      end

      return Bank.find_by!(name: row[:bank]) if row.header?(:bank) && row[:bank].present?

      nil
    end
  end
end
