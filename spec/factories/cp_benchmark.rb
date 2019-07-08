module FactoryHelper
  def fake_values(from:, to:, starting_at:)
    value = starting_at

    (from..to).map do |year|
      value -= rand(1..5)
      {year => value}
    end.reduce(&:merge)
  end
  module_function :fake_values
end

FactoryBot.define do
  factory :cp_benchmark, class: 'CP::Benchmark' do
    association :sector

    date { 5.days.ago }
    benchmarks {
      [
        {name: 'Paris pledges', values: FactoryHelper.fake_values(from: 2013, to: 2030, starting_at: 200)},
        {name: '2 Degrees', values: FactoryHelper.fake_values(from: 2013, to: 2030, starting_at: 200)},
        {name: 'Below 2 Degrees', values: FactoryHelper.fake_values(from: 2013, to: 2030, starting_at: 200)}
      ]
    }
  end
end
