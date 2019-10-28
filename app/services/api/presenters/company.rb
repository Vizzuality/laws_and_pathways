module Api
  module Presenters
    class Company
      SECTORS_LEVELS_DESC = {
        '0' => 'Unaware of Climate Change as a Business Issue',
        '1' => 'Acknowledging Climate Change as a Business Issue',
        '2' => 'Building Capacity',
        '3' => 'Integrating into Operational Decision Making',
        '4' => 'Strategic Assessment'
      }.freeze

      def initialize(company)
        @company = company
      end

      def summary
        {
          name: @company.name,
          country: @company.geography.name,
          sector: @company.sector.name,
          market_cap: @company.size.titlecase,
          isin: @company.isin,
          sedol: 60,
          ca100: @company.ca100 ? 'Yes' : 'No'
        }
      end

      def mq_assessments
        {
          latest_assessment_questions: @company.latest_mq_assessment.questions_by_level,
          levels_descriptions: SECTORS_LEVELS_DESC
        }
      end
    end
  end
end
