FactoryBot.define do
  factory :ascor_pathway, class: 'ASCOR::Pathway' do
    country factory: :ascor_country
    assessment_date { 1.year.ago }
    publication_date { 11.months.ago }
    last_reported_year { 2010 }

    emissions_metric { 'Absolute' }
    emissions_boundary { 'Production' }
    land_use { 'Total excluding LULUCF' }
    units { 'MtCO2e' }
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
    trend_1_year { '0%' }
    trend_3_year { '+6%' }
    trend_5_year { '+8%' }
  end
end
