module Api
  module Charts
    class Company
      SECTORS_LEVELS_DESC = {
        '0' => 'Unaware of Climate Change as a Business Issue',
        '1' => 'Acknowledging Climate Change as a Business Issue',
        '2' => 'Building Capacity',
        '3' => 'Integrating into Operational Decision Making',
        '4' => 'Strategic Assessment'
      }.freeze

      def details_data(company)
        {
          name: company.name,
          country: company.geography.name,
          sector: company.sector.name,
          market_cap: 'Large',
          isin: company.isin,
          sedol: 60,
          ca100: company.ca100 ? 'Yes' : 'No',
          latest_assessment: company.latest_assessment.questions.group_by { |q| q['level'] },
          levels_descriptions: SECTORS_LEVELS_DESC
        }
      end

      def emissions_data(company)
        company_emissions_data = {
          name: company.name,
          data: company.cp_assessments.last.emissions
        }

        # TODO: calculate real average from all sectors
        sectors_average_data = {
          name: "#{company.sector.name} sector mean",
          data: all_sector_assessments_emissions(company).reduce(&:merge)
        }

        sectors_cp_benchmarks = all_sector_benchmarks_emissions(company).map do |_release_date, benchmarks|
          {
            name: benchmarks.last.scenario,
            data: benchmarks.last.emissions
          }
        end

        [
          company_emissions_data,
          sectors_average_data,
          sectors_cp_benchmarks
        ].flatten
      end

      def all_sector_assessments_emissions(company)
        ::Company.includes(:cp_assessments).where(sector: company.sector).map(&:cp_assessments).flatten.map(&:emissions)
      end

      def all_sector_benchmarks_emissions(company)
        company.sector.cp_benchmarks.group_by { |b| b.release_date.to_s }
      end
    end
  end
end
