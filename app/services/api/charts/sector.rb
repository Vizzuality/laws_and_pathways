module Api
  module Charts
    class Sector
      def initialize(company_scope)
        @company_scope = company_scope
      end

      # Returns Companies summaries (name, status) grouped by their latest MQ assessments levels.
      #
      # Returns data in multiple series.
      #
      # @return [Hash]
      # @example
      #   {
      #    '1' => [
      #      { name: 'Air China', status: 'new' },
      #      { name: 'China Southern', status: 'new' }
      #    ]
      #    '3' => [
      #      { name: 'Alaska Air', status: 'up' },
      #      { name: 'IAG', status: 'down' }
      #    ]
      #   }
      def companies_summaries_by_level
        result = {
          '0' => [],
          '1' => [],
          '2' => [],
          '3' => [],
          '4' => []
        }

        companies_grouped_by_latest_assessment_level.each do |level, companies|
          result[level.to_i.to_s].concat(companies_summary(companies)).sort_by! { |c| c[:name] }
        end

        result
      end

      # Returns Companies summaries (name, status) grouped by sector and current mq level
      #
      # @return [Hash]
      # @example
      #   {
      #    'Airlines' => {
      #      '1' => [{ name: 'Air China', sector: 'Airlines', size: 'large', ... }],
      #      '2' => [{ name: 'China Southern', sector: 'Airlines', size: 'large', ... }],
      #    ]
      #    'Autos' => [
      #      '1' => [{ name: 'Tesla', sector: 'Autos', size: 'large', ... }],
      #      '3' => [{ name: 'BMW', sector: 'Airlines', size: 'large', ... }],
      #    ]
      #   }
      def companies_market_cap_by_sector
        lvls = MQ::Assessment::LEVELS.reject { |a| a == '4STAR' }

        grouped = companies_grouped_by_sector
          .map { |sector, companies| [sector, companies_market_cap(companies)] }
          .sort.to_h

        grouped_by_sectors_and_levels = grouped
          .map { |sector, companies| [sector, companies.group_by { |company| company[:level] }] }
          .sort.to_h

        grouped_by_sectors_and_levels
          .map do |sector, levels|
            lvls.each { |l| levels[l].nil? ? levels[l] = [] : '' }
            levels.reject! { |l, _c| l.nil? }
            levels.sort.to_h
            [sector, levels]
          end
          .to_h
      end

      # Returns Companies count grouped by their latest MQ assessment levels.
      #
      # Returns single series of data.
      #
      # @return [Hash]
      # @example
      #   { '0' => 13, '1' => 63, '2' => 61, '3' => 71, '4' => 63, '4STAR' => 6}
      #
      def companies_count_by_level
        companies_grouped_by_latest_assessment_level
          .map { |level, companies| [level, companies.size] }
          .sort.to_h
      end

      # Returns companies emissions, which includes:
      # - companies emissions
      # - current Sector "scenarios" emissions
      #
      # Returns data in multiple series.
      #
      # @return [Array]
      # @example
      #   [
      #     { name: 'WizzAir',   data: { '2014' => 111.0, '2015' => 112.0 } },
      #     { name: 'Air China', data: { .. } },
      #     ..
      #
      #     { name: '2 Degrees', data: { .. } }
      #   ]
      #
      def companies_emissions_data
        [
          emissions_data_from_companies,
          emissions_data_from_sector_benchmarks
        ].flatten
      end

      private

      def companies_grouped_by_latest_assessment_level
        @company_scope
          .includes(:latest_mq_assessment)
          .reject { |c| c.mq_level.nil? }
          .group_by { |c| c.mq_level.to_i.to_s }
      end

      def companies_grouped_by_sector
        @company_scope
          .includes(:sector, :latest_mq_assessment)
          .group_by { |company| company.sector.name }
      end

      def emissions_data_from_companies
        @company_scope
          .includes(:latest_cp_assessment)
          .map { |company| emissions_data_from_company(company) }
      end

      def emissions_data_from_sector_benchmarks
        @company_scope.first.latest_sector_benchmarks.map do |benchmark|
          {
            type: 'area',
            fillOpacity: 0.1,
            name: benchmark.scenario,
            data: benchmark.emissions
          }
        end
      end

      def emissions_data_from_company(company)
        {
          name: company.name,
          data: company.latest_cp_assessment&.emissions,
          lineWidth: 4
        }
      end

      def companies_summary(companies)
        companies.map do |company|
          {
            id: company.id,
            name: company.name,
            status: company.mq_status,
            level: company.mq_level
          }
        end
      end

      def companies_market_cap(companies)
        companies.map do |company|
          {
            name: company.name,
            sector: company.sector.name,
            size: company.size,
            slug: company.slug,
            level4STAR: company.is_4_star?,
            level: company.is_4_star? ? '4' : company.mq_level
          }
        end
      end
    end
  end
end
