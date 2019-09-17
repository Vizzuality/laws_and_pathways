module Api
  module Sectors
    class CompaniesCountGroupedByScenario
      CP_SCENARIOS = %w[below_2 exact_2 paris not_aligned no_disclosure].freeze

      # Returns info of how many Companies from each Sector are in given CP scenario group
      #
      # [
      #  {
      #   name: 'Below 2',
      #   data: [ ['Coal Mining', 52], ['Steel', 73] ]
      #  },
      #  {
      #    name: 'Paris',
      #    data: [ ['Coal Mining', 65], ['Steel', 26] ]
      #  }
      # ]
      def get
        CP_SCENARIOS.map do |cp_alignment|
          {
            name: get_alignment_label(cp_alignment),
            data: companies_count_per_sector_cp_scenarios(cp_alignment)
          }
        end
      end

      private

      def get_alignment_label(cp_alignment)
        {
          below_2: 'Below 2',
          exact_2: '2 degrees',
          paris: 'Paris',
          not_aligned: 'Not aligned',
          no_disclosure: 'No disclosure'
        }[cp_alignment.to_sym]
      end

      def companies_count_per_sector_cp_scenarios(_cp_alignment)
        Sector.pluck(:id, :name).map do |_sector_id, sector_name|
          [sector_name, rand(100)]
        end
      end
    end
  end
end
