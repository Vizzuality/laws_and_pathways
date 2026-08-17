require 'rails_helper'

RSpec.describe Api::Charts::CPBenchmarkColors do
  describe '.for_ordered_scenarios' do
    it 'gives the most ambitious scenario the darkest fill' do
      colors = described_class.for_ordered_scenarios(
        ['1.5 Degrees', 'Below 2 Degrees', 'National Pledges']
      )

      expect(colors).to eq(['#2465F5', '#5587F7', '#86A9F9'])
    end

    it 'uses the same grading for Paper scenario names' do
      colors = described_class.for_ordered_scenarios(
        ['Below 2 Degrees', '2 Degrees', 'Paris Pledges']
      )

      expect(colors.uniq.size).to eq(3)
      expect(colors).to eq(['#2465F5', '#5587F7', '#86A9F9'])
    end
  end
end
