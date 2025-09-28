module CSVImport
  class BankCPAssessments2025 < BankCPAssessments
    private

    def alignment_key
      :cp_alignment_2025
    end

    def update_cp_matrices_for!(assessment, row)
      super
      CP::Portfolio::NAMES.each do |portfolio_name|
        cp_matrix = assessment.cp_matrices.find_by(portfolio: portfolio_name)
        next unless cp_matrix

        cp_matrix.cp_alignment_2035 = nil
        cp_matrix.cp_alignment_2050 = nil
        cp_matrix.save!
      end
    end
  end
end
