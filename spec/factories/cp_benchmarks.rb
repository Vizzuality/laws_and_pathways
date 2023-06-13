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
#  region       :string           default("Global"), not null
#

FactoryBot.define do
  factory :cp_benchmark, class: CP::Benchmark do
    association :sector, factory: :tpi_sector

    source { 'Company' }
    release_date { 5.days.ago.to_date }
    scenario { 'Paris pledges' }
    region { 'Global' }

    emissions do
      {
        2013 => 121,
        2014 => 124,
        2015 => 125,
        2016 => 120,
        2017 => 125,
        2018 => 128
      }
    end
  end
end
