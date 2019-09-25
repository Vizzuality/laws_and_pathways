module Api
  module Charts
    class CPBenchmark
      # Returns Companies stats grouped by CP benchmark.
      #
      # Returns data in multiple series.
      #
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
        prepare_chart_data(sectors_scenarios)
      end

      private

      # Returns scenarios with sectors and companies count:
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
      def sectors_scenarios
        results = {}

        sectors_scenario_emissions.each do |sector, scenarios|
          sector.companies.each do |company|
            next if scenarios.empty?

            company_emission = company_emission(company)

            next if company_emission.zero?

            company_scenario = company_scenario(company_emission, scenarios)

            results[company_scenario] ||= Hash.new(0)
            results[company_scenario][sector.name] += 1
          end
        end

        results
      end

      # Returns emissions for all scenarios for all sectors
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

      # Determine in which scenario is current company emission
      def company_scenario(company_emission, scenarios)
        scenarios_with_greater_emission = scenarios.select do |_s, value|
          value >= company_emission
        end

        return scenarios.max.first if scenarios_with_greater_emission.empty?

        scenarios_with_greater_emission.min_by { |_s, value| value - company_emission }.first
      end

      # Returns company emission for current year or for the latest assessment
      def company_emission(company)
        emissions = company.cp_assessments.order(:assessment_date).last&.emissions

        return 0 if emissions.nil? or emissions&.empty?

        # Take emission for current year or for the last emission
        emissions[current_year] or emissions.max_by { |year| year }[1]
      end

      def current_year
        @current_year ||= Time.new.year.to_s
      end

      # Prepare data for chart based on data
      def prepare_chart_data(results)
        results.map do |scenario, companies|
          data = companies.map do |company, value|
            [company, value]
          end

          {name: scenario, data: data}
        end
      end
    end
  end
end
