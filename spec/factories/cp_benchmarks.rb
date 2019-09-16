# == Schema Information
#
# Table name: cp_benchmarks
#
#  id           :bigint           not null, primary key
#  sector_id    :bigint
#  release_date :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  emissions    :jsonb
#  scenario     :string
#

FactoryBot.define do
  factory :cp_benchmark, class: CP::Benchmark do
    association :sector

    release_date { 5.days.ago.to_date }
    scenario { ['Paris pledges', '2 Degrees', 'Below 2 Degrees'].sample }

    emissions do
      (2013..2030).map do |year|
        {year => rand(120..140)}
      end.reduce(&:merge)
    end
  end
end
