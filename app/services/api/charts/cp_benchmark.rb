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
        prepare_chart_data(sectors_cp_performance)
      end

      private

      # Prepare data for chart based on sectors cp performance data
      # @param results[Array<Hash>] list with all scenarios with emissions
      # @return [Array<Hash>] list with data for chart
      def prepare_chart_data(results)
        results.map do |scenario, companies|
          data = companies.map do |company, value|
            [company, value]
          end

          {name: scenario, data: data}
        end
      end

      # Scenarios with sectors and companies count
      # @return [Hash]
      # @example
      #   {
      #     "2 Degrees (High Efficiency)" => {
      #       "Aluminium" => 10,
      #       "Cement" => 27
      #     },
      #       "International Pledges" => {
      #       "Steel" => 80
      #     }
      #   }
      def sectors_cp_performance
        results = {}

        sectors_scenario_emissions.each do |sector, scenarios|
          sector.companies.each do |company|
            next if scenarios.empty?

            company_emission = company_emission(company)

            next unless company_emission

            company_scenario = company_scenario(company_emission, scenarios)

            results[company_scenario] ||= Hash.new(0)
            results[company_scenario][sector.name] += 1
          end
        end

        results
      end

      # Get emissions for all scenarios for all sectors
      # @return [Hash]
      # @example
      #   {"Airlines": {"Below 2 Degrees": 110, "2 Degrees": 101}}
      def sectors_scenario_emissions
        sectors = {}

        ::Sector.all.each do |sector|
          sectors[sector] = {}
          sector.cp_benchmarks.each do |benchmark|
            sectors[sector][benchmark.scenario] = benchmark.emissions[current_year]
          end
        end

        sectors
      end

      # Get company emission for current year or for the latest assessment
      # @param company [Company]
      # @return [Float]
      def company_emission(company)
        emissions = company.cp_assessments.order(:assessment_date).last&.emissions

        return if emissions.blank?

        # Take emission for current year or for the last emission
        emissions[current_year] or emissions[emissions.keys.max]
      end

      # Determine in which scenario is current company emission
      # @param company_emission [Float]
      # @param scenarios [Hash]
      def company_scenario(company_emission, scenarios)
        scenarios_with_greater_emission = scenarios.select do |_s, value|
          value >= company_emission
        end

        if scenarios_with_greater_emission.empty?
          return scenarios.max_by { |_s, value| value }.first
        end

        scenarios_with_greater_emission.min_by { |_s, value| value - company_emission }.first
      end

      # @return [String] string with current year
      def current_year
        @current_year ||= Time.new.year.to_s
      end
    end
  end
end
