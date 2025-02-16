module CSVExport
  module User
    class CompanyLatestAssessments
      def initialize(mq_assessments, cp_assessments, enable_beta_mq_assessments: false)
        @enable_beta_mq_assessments = enable_beta_mq_assessments
        @companies = (mq_assessments.map(&:company) + cp_assessments.map(&:company)).uniq
        @latest_mq_assessments_hash = get_latest_mq_assessments_hash(mq_assessments)
        @cp_assessments_hash = get_cp_assessments_hash(cp_assessments)
      end

      def call
        return if @companies.empty?

        question_headers = @latest_mq_assessments_hash.values.compact.first.questions.map(&:csv_column_name)
        year_headers = @cp_assessments_hash.values.map(&:last).flat_map(&:emissions_all_years).uniq.sort

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
          'Benchmark ID',
          'Carbon Performance Alignment 2025',
          'Carbon Performance Alignment 2027',
          'Carbon Performance Alignment 2028',
          'Carbon Performance Alignment 2035',
          'Carbon Performance Alignment 2050',
          'Years with targets',
          'Previous Carbon Performance Alignment 2025',
          'Previous Carbon Performance Alignment 2027',
          'Previous Carbon Performance Alignment 2028',
          'Previous Carbon Performance Alignment 2035',
          'Previous Carbon Performance Alignment 2050',
          'Previous Years with targets',
          'History to Projection Cutoff Year',
          'CP Unit',
          *year_headers,
          'Assumptions'
        ]

        # BOM UTF-8
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          @companies.sort_by(&:name).each do |company|
            mq_assessment = @latest_mq_assessments_hash[company.id]
            cp_assessment = @cp_assessments_hash[company.id]&.last
            prev_cp_assessment = @cp_assessments_hash[company.id]&.second_to_last

            csv << [
              company.name,
              company.geography.name,
              company.geography.iso,
              company.sector.name,
              company.ca100? ? 'Yes' : 'No',
              company.market_cap_group,
              company.isin&.tr(',', ';')&.tr(' ', ''),
              company.sedol&.tr(',', ';')&.tr(' ', ''),
              mq_assessment&.publication_date,
              mq_assessment&.assessment_date,
              mq_assessment&.level,
              mq_assessment&.status,
              question_headers.map do |header|
                mq_assessment&.find_answer_by_key(header.split('|')[0])
              end,
              cp_assessment&.publication_date,
              cp_assessment&.assessment_date,
              cp_assessment&.cp_benchmark_id,
              cp_assessment&.cp_alignment_2025,
              cp_assessment&.cp_alignment_2027,
              cp_assessment&.cp_alignment_2028,
              cp_assessment&.cp_alignment_2035,
              cp_assessment&.cp_alignment_2050,
              cp_assessment&.years_with_targets&.join(';'),
              prev_cp_assessment&.cp_alignment_2025,
              prev_cp_assessment&.cp_alignment_2027,
              prev_cp_assessment&.cp_alignment_2028,
              prev_cp_assessment&.cp_alignment_2035,
              prev_cp_assessment&.cp_alignment_2050,
              prev_cp_assessment&.years_with_targets&.join(';'),
              cp_assessment&.last_reported_year,
              cp_assessment&.unit,
              year_headers.map do |year|
                cp_assessment&.emissions.try(:[], year)
              end,
              cp_assessment&.assumptions
            ].flatten
          end
        end
      end

      private

      def get_latest_mq_assessments_hash(assessments)
        assessments = assessments.reject(&:beta_methodology?) unless @enable_beta_mq_assessments
        latest_methodology = assessments
          .select { |a| a.methodology_version.present? }
          .max_by(&:methodology_version)&.methodology_version

        assessments.group_by(&:company_id).transform_values do |grouped|
          grouped.find { |a| a.methodology_version == latest_methodology }
        end
      end

      def get_cp_assessments_hash(assessments)
        assessments.group_by(&:cp_assessmentable_id).transform_values do |grouped|
          grouped.sort_by(&:publication_date)
        end
      end
    end
  end
end
