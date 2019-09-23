module Api
  module Charts
    class Company
      attr_reader :company

      SECTORS_LEVELS_DESC = {
        '0' => 'Unaware of Climate Change as a Business Issue',
        '1' => 'Acknowledging Climate Change as a Business Issue',
        '2' => 'Building Capacity',
        '3' => 'Integrating into Operational Decision Making',
        '4' => 'Strategic Assessment'
      }.freeze

      def initialize(company)
        @company = company
      end

      def details_data
        {
          name: company.name,
          country: company.geography.name,
          sector: company.sector.name,
          market_cap: 'Large',
          isin: company.isin,
          sedol: 60,
          ca100: company.ca100 ? 'Yes' : 'No',
          latest_assessment: questions_by_level,
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
      def emissions_data
        [
          emissions_data_from_company,
          emissions_data_from_sector,
          emissions_data_from_sector_benchmarks
        ].flatten
      end

      private

      def questions_by_level
        company.latest_assessment.questions.group_by { |q| q['level'] }
      end

      def emissions_data_from_company
        {
          name: company.name,
          data: company.cp_assessments.last.emissions
        }
      end

      def emissions_data_from_sector
        {
          name: "#{company.sector.name} sector mean",
          data: sector_average_emissions
        }
      end

      def emissions_data_from_sector_benchmarks
        company.sector_benchmarks.map do |benchmark|
          {
            type: 'area',
            name: benchmark.scenario,
            data: benchmark.emissions
          }
        end
      end

      # Returns average emissions history for given Sector.
      # For each year, average value is calculated from all available
      # companies emissions, up to last reported year.
      #
      # @example {'2014' => 111.0, '2015' => 112.0 }
      #
      def sector_average_emissions
        all_years = sector_all_emissions.map(&:keys).flatten.map(&:to_i).uniq

        last_reported_year = Time.new.year
        years = (all_years.min..last_reported_year).map.to_a

        years
          .map { |year| [year, sector_average_emission_for_year(year)] }
          .to_h
      end

      # Returns average emission from all Companies from single year
      def sector_average_emission_for_year(year)
        company_emissions = sector_all_emissions
          .map { |emissions| emissions[year.to_s] }
          .compact

        (company_emissions.sum / company_emissions.count).round(2)
      end

      # Returns array of emissions ({ year => value }) from all Companies from current Sector
      def sector_all_emissions
        @sector_all_emissions ||= company.sector
          .companies
          .includes(:cp_assessments)
          .map(&:cp_assessments)
          .flatten.map(&:emissions)
      end
    end
  end
end
