module CSVExport
  module User
    class BankCPAssessments
      YEARS = %w[2025 2030 2035 2050].freeze

      def call
        # BOM UTF-8
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          cp_assessments.each do |(bank, sector), assessments|
            assessment = assessments&.first
            next if assessment.blank? || bank.blank?

            csv << [
              bank.name,
              assessment.region,
              sector&.name,
              assessment.subsector&.name,
              assessment.assessment_date,
              assessment.publication_date,
              emissions_all_years.map { |year| assessment.emissions[year] },
              assessment.assumptions,
              assessment.years_with_targets&.join(';'),
              YEARS.map do |year|
                CP::Portfolio::NAMES.map do |portfolio|
                  assessment.cp_matrices.detect { |m| m.portfolio == portfolio }&.public_send "cp_alignment_#{year}"
                end
              end
            ].flatten
          end
        end
      end

      private

      def headers
        [
          'Bank Name',
          'Region',
          'Sector',
          'Subsector',
          'Assessment Date',
          'Publication Date'
        ] +
          emissions_all_years +
          [
            'Assumptions',
            'Years with targets'
          ] +
          portfolio_for_all_years
      end

      def portfolio_for_all_years
        @portfolio_for_all_years ||= YEARS.map do |year|
          CP::Portfolio::NAMES.map { |name| "#{name} #{year}" }
        end.flatten
      end

      def emissions_all_years
        @emissions_all_years ||= cp_assessments.values.flatten.flat_map(&:emissions_all_years).uniq.sort
      end

      def cp_assessments
        @cp_assessments ||= Queries::TPI::LatestCPAssessmentsQuery.new(category: Bank).call
      end
    end
  end
end
