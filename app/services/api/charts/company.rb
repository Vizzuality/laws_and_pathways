module Api
  module Charts
    class Company
      SECTORS_LEVELS_DESC = {
        '0' => 'Unaware of Climate Change as a Business Issue',
        '1' => 'Acknowledging Climate Change as a Business Issue',
        '2' => 'Building Capacity',
        '3' => 'Integrating into Operational Decision Making',
        '4' => 'Strategic Assessment'
      }.freeze

      def details_data(company)
        {
          name: company.name,
          country: company.geography.name,
          sector: company.sector.name,
          market_cap: 'Large',
          isin: company.isin,
          sedol: 60,
          ca100: company.ca100 ? 'Yes' : 'No',
          latest_assessment: company.latest_assessment.questions.group_by { |q| q['level'] },
          levels_descriptions: SECTORS_LEVELS_DESC
        }
      end

      # Returns array of following series:
      # - company emissions
      # - company's sector average emissions
      # - company's sector CP benchmarks (scenarios)
      #
      # @example
      #   [
      #     { name: 'Air China',                   data: {'2014' => 111.0, '2015' => 112.0 } },
      #
      #     { name: 'Airlines sector mean',        data: { ... } },
      #
      #     { name: '2 Degrees (Shift-Improve)',   data: { ... } },
      #     { name: '2 Degrees (High Efficiency)', data: { ... } },
      #   ]
      #
      def emissions_data(company)
        company_emissions_data = emissions_data_series_from_company(company)

        sectors_average_data = emissions_data_series_from_sector(company.sector)

        sectors_cp_benchmarks = sector_benchmarks_emissions(company).map do |benchmark|
          emissions_data_series_from_sector_benchmark(benchmark)
        end

        [
          company_emissions_data,
          sectors_average_data,
          sectors_cp_benchmarks
        ].flatten
      end

      def sector_benchmarks_emissions(company)
        company.sector.cp_benchmarks
      end

      def emissions_data_series_from_company(company)
        {
          name: company.name,
          data: company.cp_assessments.last.emissions
        }
      end

      def emissions_data_series_from_sector_benchmark(cp_benchmark)
        {
          name: cp_benchmark.scenario,
          data: cp_benchmark.emissions
        }
      end

      # returns average from sector companies
      def emissions_data_series_from_sector(sector)
        {
          name: "#{sector.name} sector mean",
          data: all_sector_assessments_emissions(sector).reduce(&:merge) # TODO: calculate real average from all sectors
        }
      end

      def all_sector_assessments_emissions(sector)
        ::Company.includes(:cp_assessments)
          .where(sector: sector)
          .map(&:cp_assessments)
          .flatten
          .map(&:emissions)
      end
    end
  end
end
