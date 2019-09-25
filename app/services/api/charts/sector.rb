module Api
  module Charts
    class Sector
      def initialize(company_scope)
        @company_scope = company_scope
      end

      # Returns Companies summaries grouped by their latest MQ assessments Sector's levels.
      #
      # Returns data in multiple series.
      #
      # @example
      #   [
      #    ['1',
      #      [
      #        { name: 'Air China', status: 'new' },
      #        { name: 'China Southern', status: 'new' }
      #      ]
      #    ],
      #    ['3',
      #      [
      #        { name: 'Alaska Air', status: 'up' },
      #        { name: 'IAG', status: 'down' }
      #      ]
      #     ]
      #   ]
      def companies_summaries
        @company_scope
          .includes(:mq_assessments)
          .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
          .sort.to_h
          .map { |level, companies| [level, companies_summary(companies)] }
      end

      # Returns latest "MQ assessment Sector's levels" mapped to number of Companies in given level
      #
      # Returns single series of data.
      #
      # @example
      #   { '0' => 13, '1' => 63, '2' => 61, '3' => 71, '4' => 63, '4STAR' => 6}
      #
      def companies_count
        @company_scope
          .includes(:mq_assessments)
          .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
          .map { |level, companies| [level, companies.size] }
          .sort.to_h
      end

      # Returns companies emissions
      #
      # Returns data in multiple series.
      #
      # @example
      #   [
      #     { name: 'WizzAir', data: {} },
      #     { name: 'Air China', data: {'2014' => 111.0, '2015' => 112.0 } },
      #     { name: 'China Southern', data: {'2014' => 114.0, '2015' => 112.0 } }
      #   ]
      #
      def companies_emissions_data
        [
          emissions_data_from_companies,
          emissions_data_from_sector_benchmarks
        ].flatten
      end

      private

      def emissions_data_from_companies
        @company_scope
          .includes(:mq_assessments, :cp_assessments)
          .map { |company| company_emissions_series_options(company) }
      end

      def emissions_data_from_sector_benchmarks
        @company_scope.first.sector_benchmarks.map do |benchmark|
          {
            type: 'area',
            fillOpacity: 0.1,
            name: benchmark.scenario,
            data: benchmark.emissions
          }
        end
      end

      def company_emissions_series_options(company)
        {
          name: company.name,
          data: company.cp_assessments.last&.emissions,
          lineWidth: 4
        }
      end

      def companies_summary(companies)
        companies.map do |company|
          {
            id: company.id,
            name: company.name,
            status: company.mq_status
          }
        end
      end
    end
  end
end
