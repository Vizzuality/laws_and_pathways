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
          sedol: @company.sedol,
          ca100: @company.ca100 ? 'Yes' : 'No'
        )
      end

      def cp_alignment
        return unless @company.cp_alignment.present?

        CP::Alignment.new(name: @company.cp_alignment)
      end
    end
  end
end
