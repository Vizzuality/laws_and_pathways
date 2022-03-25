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

      def cp_alignment_2050
        return unless @company.cp_alignment_2050.present?

        CP::Alignment.new(name: @company.cp_alignment_2050, sector: @company.sector.name)
      end

      def cp_alignment_2025
        return unless @company.cp_alignment_2025.present?

        CP::Alignment.new(name: @company.cp_alignment_2025, sector: @company.sector.name)
      end

      def cp_alignment_2035
        return unless @company.cp_alignment_2035.present?

        CP::Alignment.new(name: @company.cp_alignment_2035, sector: @company.sector.name)
      end
    end
  end
end
