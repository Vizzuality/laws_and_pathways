module CSVExport
  module User
    class LatestMQAssessments
      def initialize(mq_assessments, enable_beta_mq_assessments: false)
        @enable_beta_mq_assessments = enable_beta_mq_assessments
        @latest_mq_assessments_hash = get_latest_mq_assessments_hash(mq_assessments)
        @companies = @latest_mq_assessments_hash.values.compact.map(&:company).uniq
      end

      def call
        return if @companies.empty?

        question_headers = @latest_mq_assessments_hash.values.compact.first&.questions&.map(&:csv_column_name) || []

        headers = [
          'Company ID',
          'Company Name',
          'Geography',
          'Geography Code',
          'Sector',
          'CA100 Focus Company',
          'Large/Medium Classification',
          'ISINs',
          'SEDOL',
          'MQ Publication Date',
          'MQ Assessment Date',
          'Fiscal Year',
          'Level',
          'Performance Compared to Previous Year',
          *question_headers
        ]

        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          @companies.sort_by(&:name).each do |company|
            mq_assessment = @latest_mq_assessments_hash[company.id]

            csv << [
              company.id,
              company.name,
              company.geography.name,
              company.geography.iso,
              company.sector&.name,
              company.ca100? ? 'Yes' : 'No',
              company.market_cap_group,
              company.isin&.tr(',', ';')&.tr(' ', ''),
              company.sedol&.tr(',', ';')&.tr(' ', ''),
              mq_assessment&.publication_date,
              mq_assessment&.assessment_date,
              mq_assessment&.fiscal_year,
              mq_assessment&.level,
              mq_assessment&.status,
              question_headers.map do |header|
                mq_assessment&.find_answer_by_key(header.split('|')[0])
              end
            ].flatten
          end
        end
      end

      private

      def get_latest_mq_assessments_hash(assessments)
        latest_methodology = assessments
          .select { |a| a.methodology_version.present? }
          .max_by(&:methodology_version)&.methodology_version

        return {} unless latest_methodology

        latest_publication_date = assessments
          .select { |a| a.methodology_version == latest_methodology }
          .max_by(&:publication_date)&.publication_date

        return {} unless latest_publication_date

        assessments
          .select { |a| a.methodology_version == latest_methodology && a.publication_date == latest_publication_date }
          .group_by(&:company_id)
          .transform_values do |grouped|
            grouped.max_by { |a| [a.publication_date, a.assessment_date] }
          end
      end
    end
  end
end

