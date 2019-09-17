module Api
  module Sectors
    class CompaniesNamesGroupedByLevel
      def initialize(company_scope)
        @company_scope = company_scope
      end

      def get
        @company_scope
          .includes(:mq_assessments)
          .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
          .sort_by { |level, _companies| level }
          .map { |level, companies| [level, companies_emissions(companies)] }
      end

      private

      def companies_emissions(companies)
        companies.map do |company|
          {
            name: company.name,
            emissions: company.cp_assessments.last&.emissions
          }
        end
      end
    end
  end
end
