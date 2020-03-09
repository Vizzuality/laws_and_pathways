module Api
  module Charts
    class MQAssessment
      attr_reader :assessment

      delegate :company, to: :assessment, allow_nil: true

      def initialize(assessment)
        @assessment = assessment
      end

      # Returns MQ assessments Levels for each year for given Company.
      #
      # @return [Array<Array>]
      # @example
      #   [ ['2016-03-01', 3], ['2017-01-01', 3], ['2018-08-20', 4]]
      # #
      def assessments_levels_data
        return [] unless company_mq_assessments.any?

        results = company_mq_assessments.map do |a|
          [a.assessment_date.to_s, a.level.to_i]
        end

        [
          {
            name: 'Level',
            data: results
          },
          {
            name: 'Current Level',
            data: [[assessment.assessment_date.to_s, assessment.level.to_i]]
          }
        ]
      end

      private

      def company_mq_assessments
        return [] unless company.present?

        @company_mq_assessments ||= company.mq_assessments.currently_published.order(:assessment_date)
      end
    end
  end
end
