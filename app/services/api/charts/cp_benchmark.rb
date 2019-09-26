module Api
  module Charts
    class CPBenchmark
      # Calculate companies stats grouped by CP benchmark in multiple series.
      # @return [Array<Hash> chart data
      # @example
      #   [
      #     {
      #       name: 'Below 2',
      #       data: [ ['Coal Mining', 52], ['Steel', 73] ]
      #     },
      #     {
      #       name: 'Paris',
      #       data: [ ['Coal Mining', 65], ['Steel', 26] ]
      #     }
      #   ]
      def cp_performance
        ::Company
          .includes(:cp_assessments, sector: [:cp_benchmarks])
          .group_by { |company| company_current_scenario(company) }
          .map do |scenario, companies|
            {
              name: scenario,
              data: companies_count_by_sector(companies)
            }
          end
      end

      private

      def companies_count_by_sector(companies)
        companies
          .group_by {|c| c.sector.name }
          .map {|sector_name, companies| [sector_name, companies.size] }
      end

      def company_current_scenario(company)
        company_last_emission = company_last_reported_emission(company)

        return nil unless company_last_emission

        sector_last_reported_emissions = company
          .sector
          .cp_benchmarks
          .map { |cp| [cp.scenario, cp.emissions[current_year]] }

        sector_last_reported_emissions
          .min_by { |_sector, sector_emission| (sector_emission - company_last_emission).abs }
          .first
      end

      # Get company emission for current year or for the latest assessment
      # @param company [Company]
      # @return [Float]
      def company_last_reported_emission(company)
        company_all_emissions = company.cp_assessments.order(:assessment_date).last&.emissions
        return if company_all_emissions.blank?

        company_last_reported_year = current_year

        company_all_emissions[company_last_reported_year] || company_all_emissions[company_all_emissions.keys.max]
      end

      # @return [String] string with current year
      def current_year
        @current_year ||= Time.new.year.to_s
      end
    end
  end
end
