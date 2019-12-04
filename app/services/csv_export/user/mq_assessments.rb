module CSVExport
  module User
    class MQAssessments
      def initialize(assessments)
        @assessments = assessments
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def call
        return if @assessments.empty?

        headers = ['Company Name', 'Geography', 'Geography Code', 'Sector',
                   'CA100 Company?', 'Large/Medium Classification',
                   'ISINs', 'SEDOL', 'Publication Date', 'Assessment Date',
                   'Level', 'Performance compared to previous year']
        question_headers = @assessments.first.questions.map(&:csv_column_name)
        headers.concat(question_headers)

        CSV.generate do |csv|
          csv << headers

          @assessments.each do |assessment|
            csv << [
              assessment.company.name,
              assessment.company.geography.name,
              assessment.company.geography.iso,
              assessment.company.sector.name,
              assessment.company.ca100? ? 'Yes' : 'No',
              assessment.company.market_cap_group,
              assessment.company.isin,
              assessment.company.sedol,
              assessment.publication_date,
              assessment.assessment_date,
              assessment.level,
              assessment.status,
              assessment.questions.map do |q|
                assessment.find_answer_by_key(q.key)
              end
            ].flatten
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
