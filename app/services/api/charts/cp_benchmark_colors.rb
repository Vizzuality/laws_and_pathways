module Api
  module Charts
    module CPBenchmarkColors
      PALETTE = ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB'].freeze
      BY_SCENARIO = {
        '1.5 Degrees' => '#2465F5',
        '2 Degrees' => '#2465F5',
        'Below 2 Degrees' => '#5587F7',
        'Paris Pledges' => '#86A9F9',
        'National Pledges' => '#86A9F9',
        'International Pledges' => '#0A4BDC'
      }.freeze

      def self.for_ordered_scenarios(scenario_names)
        used = []
        scenario_names.map.with_index do |scenario, index|
          preferred = BY_SCENARIO[scenario] || PALETTE[index % PALETTE.size]
          color = used.include?(preferred) ? (PALETTE - used).first || preferred : preferred
          used << color
          color
        end
      end
    end
  end
end
