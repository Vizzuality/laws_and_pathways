# == Schema Information
#
# Table name: cp_benchmarks
#
#  id         :bigint(8)        not null, primary key
#  sector_id  :bigint(8)
#  date       :date             not null
#  benchmarks :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :cp_benchmark, class: CP::Benchmark do
    association :sector

    date { 5.days.ago.to_date }
    benchmarks do
      fake_values = lambda do |from, to, starting_at|
        value = starting_at

        (from..to).map do |year|
          value -= rand(1..5)
          {year => value}
        end.reduce(&:merge)
      end

      [
        {name: 'Paris pledges', values: fake_values.call(2013, 2030, 200)},
        {name: '2 Degrees', values: fake_values.call(2013, 2030, 200)},
        {name: 'Below 2 Degrees', values: fake_values.call(2013, 2030, 200)}
      ]
    end
  end
end
