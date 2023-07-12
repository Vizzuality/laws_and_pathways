module CSVExport
  module User
    class CompanyCPAssessmentsRegional
      def initialize(assessments)
        @assessments = assessments
      end

      def call
        return if @assessments.empty?

        @assessments = @assessments.where.not(region: nil)

        headers = [
          'Company Name',
          'Geography',
          'Geography Code',
          'Sector',
          'CA100 Focus Company',
          'Large/Medium Classification',
          'ISINs',
          'SEDOL',
          'Publication Date',
          'Assessment Date',
          'Region',
          'Carbon Performance Regional Alignment 2025',
          'Carbon Performance Regional Alignment 2035',
          'Carbon Performance Regional Alignment 2050',
          'Regional Benchmark ID',
          'Years with targets',
          'History to Projection cutoff year',
          'CP Unit',
          'Assumptions'
        ]
        year_columns = @assessments.flat_map(&:emissions_all_years).uniq.sort
        headers.concat(year_columns)

        # BOM UTF-8
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          @assessments.each do |assessment|
            csv << [
              assessment.company.name,
              assessment.company.geography.name,
              assessment.company.geography.iso,
              assessment.company.sector.name,
              assessment.company.ca100? ? 'Yes' : 'No',
              assessment.company.market_cap_group,
              assessment.company.isin&.tr(',', ';')&.tr(' ', ''),
              assessment.company.sedol&.tr(',', ';')&.tr(' ', ''),
              assessment.publication_date,
              assessment.assessment_date,
              assessment.region,
              assessment.cp_regional_alignment_2025,
              assessment.cp_regional_alignment_2035,
              assessment.cp_regional_alignment_2050,
              assessment.cp_regional_benchmark_id,
              assessment.years_with_targets&.join(';'),
              assessment.last_reported_year,
              assessment.unit,
              assessment.assumptions,
              year_columns.map do |year|
                assessment.emissions[year]
              end
            ].flatten
          end
        end
      end
    end
  end
end
