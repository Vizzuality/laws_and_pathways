FactoryBot.define do
  factory :ascor_benchmark, class: 'ASCOR::Benchmark' do
    country factory: :ascor_country
    publication_date { '2021-09' }
    emissions_metric { 'Absolute' }
    emissions_boundary { 'Production' }
    land_use { 'Total excluding LULUCF' }
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
