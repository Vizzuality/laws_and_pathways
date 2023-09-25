# == Schema Information
#
# Table name: ascor_benchmarks
#
#  id                 :bigint           not null, primary key
#  country_id         :bigint           not null
#  publication_date   :date
#  emissions_metric   :string
#  emissions_boundary :string
#  units              :string
#  benchmark_type     :string
#  emissions          :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :ascor_benchmark, class: 'ASCOR::Benchmark' do
    country factory: :ascor_country
    publication_date { Date.new(2021, 9) }
    emissions_metric { 'Absolute' }
    emissions_boundary { 'Production - excluding LULUCF' }
    units { 'MtCO2e' }
    benchmark_type { 'National 1.5C benchmark' }
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
