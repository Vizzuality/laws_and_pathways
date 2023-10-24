require 'rails_helper'

RSpec.describe Api::ASCOR::RecentEmissions do
  subject { described_class.new(@assessment_date, @country).call }

  before_all do
    @country = create(:ascor_country, id: 1, name: 'USA', iso: 'USA')
    @assessment_date = Date.new(2019, 1, 1)

    create :ascor_pathway,
           country: @country,
           assessment_date: Date.new(2019, 1, 1),
           emissions_metric: 'Intensity per capita',
           emissions_boundary: 'Consumption - excluding LULUCF',
           units: 'MtCO2e',
           trend_1_year: '+ 6%',
           trend_3_year: '+ 8%',
           trend_5_year: '+ 9%',
           trend_source: 'source',
           trend_year: 2019,
           recent_emission_level: 100,
           recent_emission_source: 'source',
           recent_emission_year: 2019
    create :ascor_pathway,
           country: @country,
           assessment_date: Date.new(2019, 1, 1),
           emissions_metric: 'Absolute',
           emissions_boundary: 'Production - only LULUCF',
           units: 'MtCO2e',
           trend_1_year: '- 6%',
           trend_3_year: '+ 6%',
           trend_5_year: '+ 8%',
           trend_source: 'source 2',
           trend_year: 2020,
           recent_emission_level: 200,
           recent_emission_source: 'source 2',
           recent_emission_year: 2020
    create :ascor_pathway, country: create(:ascor_country, id: 2, name: 'Czechia', iso: 'CZE')
    create :ascor_pathway, country: @country, assessment_date: Date.new(2019, 2, 1)
  end

  it 'returns expected result' do
    expect(subject).to match_array(
      [
        {
          value: 100,
          source: 'source',
          year: 2019,
          unit: 'MtCO2e',
          emissions_metric: 'Intensity per capita',
          emissions_boundary: 'Consumption - excluding LULUCF',
          trend: {
            source: 'source',
            year: 2019,
            values: [
              {filter: '1 year trend', value: '+ 6%'},
              {filter: '3 years trend', value: '+ 8%'},
              {filter: '5 years trend', value: '+ 9%'}
            ]
          }
        },
        {
          value: 200,
          source: 'source 2',
          year: 2020,
          unit: 'MtCO2e',
          emissions_metric: 'Absolute',
          emissions_boundary: 'Production - only LULUCF',
          trend: {
            source: 'source 2',
            year: 2020,
            values: [
              {filter: '1 year trend', value: '- 6%'},
              {filter: '3 years trend', value: '+ 6%'},
              {filter: '5 years trend', value: '+ 8%'}
            ]
          }
        }
      ]
    )
  end
end
