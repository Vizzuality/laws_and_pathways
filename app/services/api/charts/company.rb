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
        company_latest_assessment = company.latest_assessment.questions.group_by { |q| q['level'] }

        {
          name: company.name,
          country: company.geography.name,
          sector: company.sector.name,
          market_cap: 'Large',
          isin: company.isin,
          sedol: 60,
          ca100: company.ca100 ? 'Yes' : 'No',
          latest_assessment: company_latest_assessment,
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
        [
          emissions_data_series_from_company(company),
          emissions_data_series_from_sector(company.sector),
          company.sector_benchmarks.map do |benchmark|
            emissions_data_series_from_sector_benchmark(benchmark)
          end
        ].flatten
      end

      private

      def emissions_data_series_from_company(company)
        {
          name: company.name,
          data: company.cp_assessments.last.emissions
        }
      end

      def emissions_data_series_from_sector_benchmark(cp_benchmark)
        {
          type: 'area',
          name: cp_benchmark.scenario,
          data: cp_benchmark.emissions
        }
      end

      # returns average from sector companies
      def emissions_data_series_from_sector(sector)
        {
          name: "#{sector.name} sector mean",
          data: sector_average_emissions(sector)
        }
      end

      # Returns average emissions history for given Sector.
      # For each year, average value is calculated from all available companies emissions,
      # up to last reported year.
      #
      # @example {'2014' => 111.0, '2015' => 112.0 }
      #
      def sector_average_emissions(sector)
        all_sector_emissions = sector_all_emissions(sector)
        all_years = all_sector_emissions.map(&:keys).flatten.map(&:to_i).uniq

        last_reported_year = Time.new.year
        years = (all_years.min..last_reported_year).map.to_a

        sector_average_for_year = lambda do |year|
          company_emissions = all_sector_emissions.map { |emissions| emissions[year.to_s] }.compact
          (company_emissions.sum / company_emissions.count).round(2)
        end

        years.map { |year| [year, sector_average_for_year.call(year)] }.to_h
      end

      def sector_all_emissions(sector)
        sector
          .companies
          .includes(:cp_assessments)
          .map(&:cp_assessments)
          .flatten.map(&:emissions)
      end
    end
  end
end
