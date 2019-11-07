module Api
  module Presenters
    class Company
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
    end
  end
end
