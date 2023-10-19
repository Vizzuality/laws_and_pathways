# == Schema Information
#
# Table name: ascor_pathways
#
#  id                     :bigint           not null, primary key
#  country_id             :bigint           not null
#  emissions_metric       :string
#  emissions_boundary     :string
#  units                  :string
#  assessment_date        :date
#  publication_date       :date
#  last_historical_year   :integer
#  trend_1_year           :string
#  trend_3_year           :string
#  trend_5_year           :string
#  emissions              :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  trend_source           :string
#  trend_year             :integer
#  recent_emission_level  :float
#  recent_emission_source :string
#  recent_emission_year   :integer
#
FactoryBot.define do
  factory :ascor_pathway, class: 'ASCOR::Pathway' do
    country factory: :ascor_country
    assessment_date { Date.new(2021, 9, 10) }
    publication_date { Date.new(2022, 1) }
    last_historical_year { 2010 }

    emissions_metric { 'Absolute' }
    emissions_boundary { 'Production - excluding LULUCF' }
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
    trend_source { 'https://zenodo.org/record/7727481' }
    trend_year { 2018 }
    recent_emission_level { 128 }
    recent_emission_source { 'https://zenodo.org/record/7727481' }
    recent_emission_year { 2018 }
  end
end
