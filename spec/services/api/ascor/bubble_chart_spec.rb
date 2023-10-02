require 'rails_helper'

RSpec.describe Api::ASCOR::BubbleChart do
  subject { described_class.new(assessment_date).call }

  before_all do
    usa = create(:ascor_country, id: 1, name: 'USA', iso: 'USA')
    japan = create(:ascor_country, id: 2, name: 'Japan', iso: 'JPN')

    _indicator_pillar_1 = create(:ascor_assessment_indicator, id: 1, code: 'EP', indicator_type: :pillar,
                                                              text: 'Emissions Performance')
    _indicator_pillar_2 = create(:ascor_assessment_indicator, id: 2, code: 'CP', indicator_type: :pillar,
                                                              text: 'Climate Performance')
    indicator_area_1 = create(:ascor_assessment_indicator, id: 3, code: 'EP.1', indicator_type: :area,
                                                           text: 'Emissions Performance 1')
    indicator_area_2 = create(:ascor_assessment_indicator, id: 4, code: 'EP.2', indicator_type: :area,
                                                           text: 'Emissions Performance 2')
    indicator_area_3 = create(:ascor_assessment_indicator, id: 5, code: 'CP.1', indicator_type: :area,
                                                           text: 'Climate Performance 1')

    create :ascor_assessment, country: usa, assessment_date: Date.new(2019, 1, 1), results: [
      build(:ascor_assessment_result, indicator: indicator_area_1, answer: 'Yes'),
      build(:ascor_assessment_result, indicator: indicator_area_2, answer: 'No'),
      build(:ascor_assessment_result, indicator: indicator_area_3, answer: 'Yes')
    ]
    create :ascor_assessment, country: usa, assessment_date: Date.new(2019, 2, 1), results: [
      build(:ascor_assessment_result, indicator: indicator_area_1, answer: 'Yes'),
      build(:ascor_assessment_result, indicator: indicator_area_2, answer: 'No'),
      build(:ascor_assessment_result, indicator: indicator_area_3, answer: 'No')
    ]
    create :ascor_assessment, country: japan, assessment_date: Date.new(2019, 2, 1), results: [
      build(:ascor_assessment_result, indicator: indicator_area_1, answer: 'No'),
      build(:ascor_assessment_result, indicator: indicator_area_2, answer: 'Yes'),
      build(:ascor_assessment_result, indicator: indicator_area_3, answer: 'No')
    ]

    create :ascor_pathway, country: usa, assessment_date: Date.new(2019, 1, 1), emissions_metric: 'Intensity per capita',
                           emissions_boundary: 'Production - excluding LULUCF', recent_emission_level: 100
    create :ascor_pathway, country: usa, assessment_date: Date.new(2019, 2, 1), emissions_metric: 'Intensity per capita',
                           emissions_boundary: 'Production - excluding LULUCF', recent_emission_level: 200
    create :ascor_pathway, country: japan, assessment_date: Date.new(2019, 2, 1), emissions_metric: 'Intensity per capita',
                           emissions_boundary: 'Production - excluding LULUCF', recent_emission_level: 300
  end

  let(:assessment_date) { Date.new(2019, 2, 1) }

  it 'returns the correct data' do
    expect(subject).to match_array(
      [{
        pillar: 'Emissions Performance',
        area: 'Emissions Performance 1',
        result: 'Yes',
        country_id: 1,
        country_name: 'USA',
        country_path: '/ascor/usa',
        market_cap_group: :small
      },
       {
         pillar: 'Emissions Performance',
         area: 'Emissions Performance 1',
         result: 'No',
         country_id: 2,
         country_name: 'Japan',
         country_path: '/ascor/japan',
         market_cap_group: :large
       },
       {
         pillar: 'Emissions Performance',
         area: 'Emissions Performance 2',
         result: 'No',
         country_id: 1,
         country_name: 'USA',
         country_path: '/ascor/usa',
         market_cap_group: :small
       },
       {
         pillar: 'Emissions Performance',
         area: 'Emissions Performance 2',
         result: 'Yes',
         country_id: 2,
         country_name: 'Japan',
         country_path: '/ascor/japan',
         market_cap_group: :large
       },
       {
         pillar: 'Climate Performance',
         area: 'Climate Performance 1',
         result: 'No',
         country_id: 1,
         country_name: 'USA',
         country_path: '/ascor/usa',
         market_cap_group: :small
       },
       {
         pillar: 'Climate Performance',
         area: 'Climate Performance 1',
         result: 'No',
         country_id: 2,
         country_name: 'Japan',
         country_path: '/ascor/japan',
         market_cap_group: :large
       }]
    )
  end
end
