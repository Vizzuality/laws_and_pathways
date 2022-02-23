module CSVExport
  module User
    class CPAssessments
      def initialize(assessments)
        @assessments = assessments
      end

      def call
        return if @assessments.empty?

        headers = ['Company Name', 'Geography', 'Geography Code', 'Sector',
                   'CA100 Focus Company', 'Large/Medium Classification',
                   'ISINs', 'SEDOL', 'Publication Date', 'Assessment Date', 'Carbon Performance Alignment', 'Benchmark ID',
                   'History to Projection cutoff year', 'CP Unit', 'Assumptions']
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
              assessment.company.isin,
              assessment.company.sedol,
              assessment.publication_date,
              assessment.assessment_date,
              assessment.cp_alignment,
              assessment.cp_benchmark_id,
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
