module Api
  module Charts
    class Sector
      BENCHMARK_FILL_COLORS = ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB'].freeze
      DEFAULT_EMPTY_LEVELS = {
        '0' => [],
        '1' => [],
        '2' => [],
        '3' => [],
        '4' => [],
        '5' => []
      }.freeze

      def initialize(company_scope, enable_beta_mq_assessments: false)
        @company_scope = company_scope
        @enable_beta_mq_assessments = enable_beta_mq_assessments
        @beta_levels = MQ::Assessment::BETA_LEVELS.each_with_object({}) { |l, r| r[l] = [] }
        @empty_levels = (enable_beta_mq_assessments ? DEFAULT_EMPTY_LEVELS.merge(@beta_levels) : DEFAULT_EMPTY_LEVELS).deep_dup
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
        result = @empty_levels
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
      #      '1' => [{ name: 'Air China', sector: 'Airlines', market_cap_group: 'large', ... }],
      #      '2' => [{ name: 'China Southern', sector: 'Airlines', market_cap_group: 'large', ... }],
      #    ]
      #    'Autos' => [
      #      '1' => [{ name: 'Tesla', sector: 'Autos', market_cap_group: 'large', ... }],
      #      '3' => [{ name: 'BMW', sector: 'Airlines', market_cap_group: 'large', ... }],
      #    ]
      #   }
      def companies_market_cap_by_sector
        companies_grouped_by_sector.map do |sector, companies|
          [
            sector,
            @empty_levels.merge(
              companies_market_cap(companies).group_by { |c| c[:level] }.sort.to_h
            )
          ]
        end.sort.to_h
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
        result = @empty_levels.transform_values(&:size)
        companies_grouped_by_latest_assessment_level.each do |level, companies|
          result[level.to_i.to_s] = companies.size
        end
        result.sort.to_h
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
          emissions_data_from_sector_benchmarks,
          emissions_data_from_companies
        ].flatten
      end

      private

      def companies_grouped_by_latest_assessment_level
        @company_scope
          .includes(
            :latest_mq_assessment_without_beta_methodologies,
            :latest_mq_assessment_only_beta_methodologies
          )
          .map { |c| update_beta_mq_assessments_visibility c }
          .reject { |c| c.mq_level.nil? }
          .group_by { |c| c.mq_level.to_i.to_s }
      end

      def companies_grouped_by_sector
        @company_scope
          .includes(
            :sector,
            :latest_mq_assessment_without_beta_methodologies,
            :latest_mq_assessment_only_beta_methodologies
          )
          .map { |c| update_beta_mq_assessments_visibility c }
          .group_by { |company| company.sector.name }
      end

      def emissions_data_from_companies
        @company_scope
          .includes(:latest_cp_assessment, :geography)
          .flat_map { |company| emissions_data_from_company(company) }
          .reject { |company_data| company_data[:data].empty? }
      end

      def emissions_data_from_sector_benchmarks
        company = @company_scope.first
        return if company.nil?

        sector = company.sector

        benchmarks = sector
          .latest_released_benchmarks(category: Company, region: 'Global')
          .sort_by(&:average_emission)

        benchmarks.map.with_index do |benchmark, index|
          has_subsector = benchmark&.subsector.present?
          name = has_subsector ? "#{benchmark.scenario} - #{benchmark.subsector}" : benchmark.scenario
          {
            type: 'area',
            color: BENCHMARK_FILL_COLORS[index],
            fillColor: BENCHMARK_FILL_COLORS[index],
            name: name,
            data: emissions_data_as_numbers(benchmark&.emissions),
            sector: sector.name,
            subsector: benchmark&.subsector
          }
        end.reverse
      end

      def get_cp_assessments(company)
        unless company.latest_cp_assessments_by_subsector.present?
          return [] unless company.latest_cp_assessment.present?

          return [company.latest_cp_assessment]
        end

        company.latest_cp_assessments_by_subsector
      end

      def emissions_data_from_company(company)
        assessments_to_process = get_cp_assessments(company)

        assessments_to_process.map do |assessment|
          subsector_present = assessment.company_subsector.present?
          subsector = subsector_present ? assessment.company_subsector&.subsector : nil
          graph_name = subsector_present ? "#{company.name} - #{subsector}" : company.name
          {
            name: graph_name,
            company: {
              id: company.id,
              name: graph_name,
              region: company.geography&.region,
              geography_id: company.geography_id,
              geography_name: company.geography&.name,
              market_cap_group: company.market_cap_group,
              subsector: subsector
            },
            sector: company.sector.name,
            data: emissions_data_as_numbers(assessment&.emissions),
            zoneAxis: 'x',
            zones: [{
              value: (assessment&.last_reported_year&.to_i || 0) + 0.1
            }, {
              dashStyle: 'dot'
            }]
          }
        end
      end

      def companies_summary(companies)
        companies.map do |company|
          {
            id: company.id,
            name: company.name,
            status: company.mq_status,
            slug: company.slug,
            level: company.mq_level
          }
        end
      end

      def companies_market_cap(companies)
        companies.map do |company|
          {
            name: company.name,
            sector: company.sector.name,
            market_cap_group: company.market_cap_group,
            slug: company.slug,
            path: company.path,
            level4STAR: company.is_4_star?,
            level: company.mq_level.to_i.to_s,
            status: company.mq_status
          }
        end
      end

      def emissions_data_as_numbers(emissions)
        return {} unless emissions

        emissions.transform_keys(&:to_i)
      end

      def update_beta_mq_assessments_visibility(company)
        company.show_beta_mq_assessments = @enable_beta_mq_assessments
        company
      end

      def keep_only_beta_mq_assessments(companies)
        companies.select { |c| c.latest_mq_assessment.beta_methodology? }
      end
    end
  end
end
