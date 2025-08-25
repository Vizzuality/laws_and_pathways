module Api
  module Charts
    class CPMatrix
      attr_accessor :cp_assessmentable

      def initialize(cp_assessmentable)
        @cp_assessmentable = cp_assessmentable
      end

      def matrix_data
        {data: collect_data, meta: collect_metadata}
      end

      private

      def collect_data
        return [] unless cp_assessmentable.present?

        %w[2030 2035 2050].each_with_object({}) do |year, result|
          result[year] = sectors.each_with_object({}) do |sector, section|
            cp_assessment = cp_assessments[[cp_assessmentable, sector]]&.first
            portfolio_values = portfolio_values_from cp_assessment, year
            section[sector.name] = {
              assumptions: assumption_for(cp_assessment&.assumptions),
              portfolio_values: portfolio_values,
              has_emissions: cp_assessment&.emissions&.present?
            }
          end
        end
      end

      def assumption_for(value)
        return nil if value.blank? || value == '0'

        value
      end

      def portfolio_values_from(cp_assessment, year)
        CP::Portfolio::NAMES.each_with_object({}) do |portfolio, row|
          old_portfolio = CP::Portfolio::NAME_MAP[portfolio]
          # keep support for old portfolio names but also support new ones
          value = cp_assessment&.cp_matrices&.detect { |m| m.portfolio == old_portfolio || m.portfolio == portfolio }
          row[portfolio] = value&.public_send "cp_alignment_#{year}"
        end
      end

      def collect_metadata
        {
          sectors: sectors.map(&:name),
          portfolios: CP::Portfolio::NAMES_WITH_CATEGORIES
        }
      end

      def cp_assessments
        @cp_assessments ||= Queries::TPI::LatestCPAssessmentsQuery
          .new(category: cp_assessmentable_type, cp_assessmentable: cp_assessmentable).call
      end

      def sectors
        @sectors ||= TPISector.for_category(cp_assessmentable_type).order(:name)
      end

      def cp_assessmentable_type
        cp_assessmentable.class.to_s
      end
    end
  end
end
