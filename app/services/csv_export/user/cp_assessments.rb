module CSVExport
  module User
    class CPAssessments
      def initialize(assessments)
        @assessments = assessments
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def call
        return if @assessments.empty?

        headers = ['Company Name', 'Country Code', 'Sector Code', 'CA100 Company?', 'Large/Medium Classification',
                   'ISINs', 'SEDOL', 'Publication Date', 'Assessment Date', 'Carbon Performance Alignment',
                   'History to Projection cutoff year']
        year_columns = @assessments.flat_map(&:emissions_all_years).uniq.sort
        headers.concat(year_columns) << 'Assumptions'

        CSV.generate do |csv|
          csv << headers

          @assessments.each do |assessment|
            csv << [
              assessment.company.name,
              assessment.company.geography.iso,
              assessment.company.sector.name,
              assessment.company.ca100? ? 'Yes' : 'No',
              assessment.company.market_cap_group,
              assessment.company.isin,
              assessment.company.sedol,
              assessment.publication_date,
              assessment.assessment_date,
              assessment.cp_alignment,
              assessment.last_reported_year,
              year_columns.map do |year|
                assessment.emissions[year]
              end,
              assessment.assumptions
            ].flatten
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
