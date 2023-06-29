module Api
  module Charts
    class CPMatrix
      attr_accessor :cp_assessmentable

      def initialize(cp_assessmentable)
        @cp_assessmentable = cp_assessmentable
      end

      def matrix_data
        return [] unless cp_assessmentable.present?

        %w[2025 2035 2050].each_with_object({}) do |year, result|
          result[year] = sectors.each_with_object({}) do |sector, section|
            cp_assessment = cp_assessments[[cp_assessmentable, sector]]&.first
            section[sector.name] = CP::Portfolio::NAMES.each_with_object({}) do |portfolio, row|
              value = cp_assessment&.cp_matrices&.detect { |m| m.portfolio == portfolio }
              row[portfolio] = value&.public_send "cp_alignment_#{year}"
            end
          end
        end
      end

      private

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
