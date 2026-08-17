module Api
  module Charts
    module CPBenchmarkColors
      PALETTE = ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB'].freeze

      def self.for_ordered_scenarios(scenario_names)
        count = scenario_names.size

        scenario_names.each_index.map do |index|
          PALETTE[[count - 1 - index, PALETTE.length - 1].min]
        end
      end
    end
  end
end
