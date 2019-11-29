module Api
  module Presenters
    class Company
      CP_ALIGNMENT_COLORS = {
        '#00C170' => ['below 2 degrees', '2 degrees (high efficiency)'], # green
        '#FFDD49' => ['2 degrees', '2 degrees (shift-improve)'], # yellow
        '#FF9600' => ['paris pledges', 'international pledges'], # orange
        '#ED3D4A' => ['not aligned'], # red
        '#191919' => ['no disclosure'] # black
      }.freeze

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

      def cp_alignment
        OpenStruct.new(
          color: map_cp_alignment_color,
          text: @company.cp_alignment
        )
      end

      private

      def map_cp_alignment_color
        CP_ALIGNMENT_COLORS.select { |_k, v| v.include?(@company.cp_alignment&.downcase) }.keys.first || '#191919'
      end
    end
  end
end
