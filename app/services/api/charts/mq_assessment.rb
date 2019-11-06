module Api
  module Charts
    class MQAssessment
      attr_reader :assessment

      delegate :company, to: :assessment

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
        return [] unless previous_and_current_assessments.any?

        # we are adding first and last point with nil value to have those ticks on the chart
        # to fool Highcharts
        first_point = [previous_and_current_assessments.first.assessment_date.beginning_of_year.to_s, nil]
        last_point = [Time.now.to_date.to_s, nil]

        results = [first_point]
        previous_and_current_assessments.each do |a|
          results << [a.assessment_date.to_s, a.level]
        end
        results << last_point
      end

      private

      def previous_and_current_assessments
        [assessment.previous_assessments, assessment].flatten
      end
    end
  end
end
