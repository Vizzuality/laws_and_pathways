module CSVExport
  module User
    class CompanyLatestAssessments
      def initialize(mq_assessments, cp_assessments, current_user)
        @companies = (mq_assessments.map(&:company) + cp_assessments.map(&:company)).uniq
        @latest_mq_assessments_hash = get_latest_mq_assessments_hash(mq_assessments)
        @latest_cp_assessments_hash = get_latest_cp_assessments_hash(cp_assessments)
        @current_user = current_user
      end

      def call
        return if @companies.empty?

        question_headers = @latest_mq_assessments_hash.values.compact.first.questions.map(&:csv_column_name)
        year_headers = @latest_cp_assessments_hash.values.flat_map(&:emissions_all_years).uniq.sort

        headers = [
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
          'Level',
          'Performance Compared to Previous Year',
          *question_headers,
          'CP Publication Date',
          'CP Assessment Date',
          'Carbon Performance Alignment',
          'Carbon Performance Alignment Year',
          'History to Projection Cutoff Year',
          'CP Unit',
          *year_headers,
          'Assumptions'
        ]

        headers = headers.reject { |h| h == 'Carbon Performance Alignment Year' } unless @current_user.present?

        # BOM UTF-8
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          @companies.sort_by(&:name).each do |company|
            mq_assessment = @latest_mq_assessments_hash[company.id]
            cp_assessment = @latest_cp_assessments_hash[company.id]

            csv << [
              company.name,
              company.geography.name,
              company.geography.iso,
              company.sector.name,
              company.ca100? ? 'Yes' : 'No',
              company.market_cap_group,
              company.isin,
              company.sedol,
              mq_assessment&.publication_date,
              mq_assessment&.assessment_date,
              mq_assessment&.level,
              mq_assessment&.status,
              question_headers.map do |header|
                mq_assessment&.find_answer_by_key(header.split('|')[0])
              end,
              cp_assessment&.publication_date,
              cp_assessment&.assessment_date,
              cp_assessment&.cp_alignment,
              @current_user.present? ? cp_assessment&.cp_alignment_year : '**remove**',
              cp_assessment&.last_reported_year,
              cp_assessment&.unit,
              year_headers.map do |year|
                cp_assessment&.emissions.try(:[], year)
              end,
              cp_assessment&.assumptions
            ].reject { |v| v == '**remove**' }.flatten
          end
        end
      end

      private

      def get_latest_mq_assessments_hash(assessments)
        latest_methodology = assessments
          .select { |a| a.methodology_version.present? }
          .max_by(&:methodology_version)&.methodology_version

        assessments.group_by(&:company_id).transform_values do |grouped|
          grouped.find { |a| a.methodology_version == latest_methodology }
        end
      end

      def get_latest_cp_assessments_hash(assessments)
        assessments.group_by(&:company_id).transform_values do |grouped|
          grouped.max_by(&:publication_date)
        end
      end
    end
  end
end
