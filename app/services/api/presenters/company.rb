module Api
  module Presenters
    class Company
      def initialize(company)
        @company = company
      end

      def summary
        OpenStruct.new(
          name: @company.name,
          country: @company.geography.name,
          sector: @company.sector.name,
          market_cap: @company.market_cap_group.titlecase,
          isin: @company.isin,
          sedol: 60,
          ca100: @company.ca100 ? 'Yes' : 'No'
        )
      end

      def model
        @company
      end

      def cp_alignment
        CP::Alignment.new(name: @company.cp_alignment)
      end
    end
  end
end
