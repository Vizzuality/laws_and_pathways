module Api
  module Charts
    class Company
      def initialize(company)
        @company = company
      end

      # Returns array of following series:
      # - company emissions
      # - company's sector average emissions
      # - company's sector CP benchmarks (scenarios)
      #
      # @return [Array]
      # @example
      #   [
      #     { name: 'Air China',                   data: { '2014' => 111.0, '2015' => 112.0 } },
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

      # Returns MQ assessments Levels for each year for given Company.
      # If for given year Company has no assessment, previous level is returned.
      #
      # @return [Array<Array>]
      # @example
      #   [ [2016, 3], [2017, 3], [2018, 4]]
      # #
      def assessments_levels_data
        (oldest_mq_assessment_year..current_year).map do |year|
          [year, mq_assessment_level_for_year(year)]
        end
      end

      private

      def oldest_mq_assessment_year
        @company.oldest_mq_assessment.assessment_date.year
      end

      def mq_assessment_level_for_year(year)
        @company.mq_assessments.by_assessment_year(year).first&.level
      end

      def emissions_data_from_company
        {
          name: @company.name,
          data: @company.latest_cp_assessment&.emissions
        }
      end

      def emissions_data_from_sector
        {
          name: "#{@company.sector.name} sector mean",
          data: sector_average_emissions
        }
      end

      def emissions_data_from_sector_benchmarks
        @company.latest_sector_benchmarks_before_last_assessment.map do |benchmark|
          {
            type: 'area',
            fillOpacity: 0.1,
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
        years_with_reported_emissions
          .map { |year| [year.to_s, sector_average_emission_for_year(year)] }
          .to_h
      end

      # @return [Float] average emission from all Companies from single year
      def sector_average_emission_for_year(year)
        company_emissions = sector_all_emissions
          .map { |emissions| emissions[year.to_s] }
          .compact

        (company_emissions.sum / company_emissions.count).round(2)
      end

      # @return [Array] of years for which emissions was reported
      def years_with_reported_emissions
        (sector_all_emission_years.min..sector_last_reported_year).map.to_a
      end

      # @return [Array] unique array of years as numbers
      def sector_all_emission_years
        sector_all_emissions
          .flat_map(&:keys)
          .map(&:to_i)
          .uniq
      end

      # @return [Array<Hash>] list of { year => value } pairs from all Companies from current Sector
      def sector_all_emissions
        @sector_all_emissions ||= @company.sector
          .companies
          .includes(:cp_assessments)
          .flat_map { |c| c.latest_cp_assessment.emissions }
      end

      # @return [Integer]
      def sector_last_reported_year
        # TODO: change to last reported year (to be done in https://www.pivotaltracker.com/story/show/168850542)
        current_year
      end

      # @return [Integer]
      def current_year
        Time.new.year
      end
    end
  end
end
