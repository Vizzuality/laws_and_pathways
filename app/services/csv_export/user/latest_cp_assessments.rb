module CSVExport
  module User
    class LatestCPAssessments
      def initialize(cp_assessments)
        @cp_assessments_hash = get_cp_assessments_hash(cp_assessments)
        @companies = cp_assessments.map(&:company).uniq
      end

      def call
        return if @companies.empty?

        year_headers = @cp_assessments_hash.values.compact.flat_map { |assessments| assessments.last&.emissions_all_years }.compact.uniq.sort

        headers = [
          'Company ID',
          'Company Name',
          'Geography',
          'Geography Code',
          'Sector',
          'Subsector',
          'CA100 Focus Company',
          'Large/Medium Classification',
          'ISINs',
          'SEDOL',
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

        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          @companies.sort_by(&:name).each do |company|
            company_cp_assessments = @cp_assessments_hash[company.id]
            by_subsector = {}
            company_cp_assessments&.each do |assessment|
              next if assessment.company_subsector.nil?

              by_subsector[assessment.company_subsector.subsector] ||= []
              by_subsector[assessment.company_subsector.subsector] << assessment
            end

            by_subsector[''] = company_cp_assessments if by_subsector.empty?

            by_subsector.each do |subsector, assessments|
              cp_assessment = assessments&.last
              prev_cp_assessment = assessments&.second_to_last

              csv << [
                company.id,
                company.name,
                company.geography.name,
                company.geography.iso,
                company.sector&.name,
                subsector,
                company.ca100? ? 'Yes' : 'No',
                company.market_cap_group,
                company.isin&.tr(',', ';')&.tr(' ', ''),
                company.sedol&.tr(',', ';')&.tr(' ', ''),
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
      end

      private

      def get_cp_assessments_hash(assessments)
        assessments.group_by(&:cp_assessmentable_id).transform_values do |grouped|
          grouped.sort_by(&:publication_date)
        end
      end
    end
  end
end

