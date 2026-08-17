require 'rails_helper'

RSpec.describe Api::Charts::CPBenchmarkColors do
  describe '.for_ordered_scenarios' do
    it 'gives Paper scenarios three distinct colors' do
      colors = described_class.for_ordered_scenarios(
        ['Below 2 Degrees', '2 Degrees', 'Paris Pledges']
      )

      expect(colors.uniq.size).to eq(3)
      expect(colors).to eq(['#5587F7', '#2465F5', '#86A9F9'])
    end

    it 'does not reuse a palette color when a named scenario already claimed it' do
      colors = described_class.for_ordered_scenarios(
        ['Below 2 Degrees', 'Unnamed scenario', 'Paris Pledges']
      )

      expect(colors.uniq.size).to eq(3)
      expect(colors[0]).to eq('#5587F7')
      expect(colors[1]).not_to eq('#5587F7')
    end
  end
end
