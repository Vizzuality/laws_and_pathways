module Api
  module Sectors
    class CompaniesGroupedByLevel
      def initialize(company_scope)
        @company_scope = company_scope
      end

      # Returns Companies grouped by their latest MQ assessments Sector's levels
      #
      # [
      #  ['1',
      #    [
      #      { name: 'Air China', emissions: { 2013: 153, 2014: 142 }, status: '' },
      #      { name: 'China Southern', emissions: { 2015: 32, 2016: 43 }, status: '' }
      #    ]
      #  ],
      #  ['3',
      #    [
      #      { name: 'Alaska Air', emissions: { }, status: '' },
      #      { name: 'IAG', emissions: { }, status: '' }
      #    ]
      #   ]
      # ]
      def get
        @company_scope
          .includes(:mq_assessments)
          .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
          .sort_by { |level, _companies| level }
          .map { |level, companies| [level, companies_emissions(companies)] }
      end

      #   [
      #     ['0', 13],
      #     ['1', 63],
      #     ['2', 61],
      #     ['3', 71],
      #     ['4', 63],
      #     ['4STAR', 6]
      #   ]
      #
      def count
        @company_scope
          .includes(:mq_assessments)
          .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
          .sort_by { |level, _companies| level }
          .map { |level, companies| [level, companies_emissions(companies)] }
          .map { |level, companies| [level, companies.size] }
      end

      #   [
      #     { name: 'WizzAir', data: {} },
      #     { name: 'Air China', data: {'2014' => 111.0, '2015' => 112.0 } },
      #     { name: 'China Southern', data: {'2014' => 114.0, '2015' => 112.0 } }
      #   ]
      #
      def emissions
        @company_scope
          .includes(:mq_assessments)
          .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
          .sort_by { |level, _companies| level }
          .map { |level, companies| [level, companies_emissions(companies)] }
          .map { |_level, companies| companies }
          .flatten
          .map { |company| series_options(company[:emissions], company[:name]) }
      end

      def series_options(data, series_name)
        {
          name: series_name,
          data: data,
          lineWidth: 4
        }
      end

      private

      def companies_emissions(companies)
        companies.map do |company|
          {
            name: company.name,
            status: company.mq_status,
            emissions: company.cp_assessments.last&.emissions || {}
          }
        end
      end
    end
  end
end
