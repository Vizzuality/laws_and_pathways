require 'rails_helper'

RSpec.describe Api::ASCOR::EmissionsChart do
  subject { described_class.new(assessment_date, emissions_metric, emissions_boundary, country_ids).call }

  before_all do
    @usa = create(:ascor_country, id: 1, name: 'USA', iso: 'USA')
    @czechia = create(:ascor_country, id: 2, name: 'Czechia', iso: 'CZE')

    create :ascor_pathway,
           country: @usa,
           assessment_date: Date.new(2019, 1, 1),
           emissions_metric: 'Intensity per capita',
           emissions_boundary: 'Consumption - excluding LULUCF',
           emissions: {2013 => 100, 2014 => 100, 2015 => 100}
    create :ascor_pathway,
           country: @usa,
           assessment_date: Date.new(2019, 2, 1),
           emissions_metric: 'Intensity per capita',
           emissions_boundary: 'Consumption - excluding LULUCF',
           emissions: {2013 => 110, 2014 => 110, 2015 => 110}
    create :ascor_pathway,
           country: @czechia,
           assessment_date: Date.new(2019, 2, 1),
           emissions_metric: 'Intensity per capita',
           emissions_boundary: 'Consumption - excluding LULUCF',
           emissions: {2013 => 120, 2014 => 120, 2015 => 120}
    create :ascor_pathway,
           country: @usa,
           assessment_date: Date.new(2019, 2, 1),
           emissions_metric: 'Absolute',
           emissions_boundary: 'Production - excluding LULUCF',
           emissions: {2013 => 130, 2014 => 130, 2015 => 130}
    create :ascor_pathway,
           country: @czechia,
           assessment_date: Date.new(2019, 2, 1),
           emissions_metric: 'Absolute',
           emissions_boundary: 'Production - excluding LULUCF',
           emissions: {2013 => 140, 2014 => 140, 2015 => 140}
  end

  let(:assessment_date) { Date.new(2019, 2, 1) }
  let(:emissions_metric) { 'Intensity per capita' }
  let(:emissions_boundary) { 'Consumption - excluding LULUCF' }
  let(:country_ids) { [@usa.id, @czechia.id] }

  it 'returns expected result' do
    expect(subject).to eq(
      data: {
        @usa.id => {
          emissions: {'2013' => 110, '2014' => 110, '2015' => 110},
          last_historical_year: 2010
        },
        @czechia.id => {
          emissions: {'2013' => 120, '2014' => 120, '2015' => 120},
          last_historical_year: 2010
        }
      },
      metadata: {unit: 'MtCO2e'}
    )
  end

  context 'when country_ids are nil' do
    let(:country_ids) { nil }

    it 'returns expected result' do
      expect(subject).to eq(
        data: {
          @usa.id => {
            emissions: {'2013' => 110, '2014' => 110, '2015' => 110},
            last_historical_year: 2010
          }
        },
        metadata: {unit: 'MtCO2e'}
      )
    end
  end

  context 'when emissions_metric and emissions_boundary is nil' do
    let(:emissions_metric) { nil }
    let(:emissions_boundary) { nil }

    it 'returns expected result' do
      expect(subject).to eq(
        data: {
          @usa.id => {
            emissions: {'2013' => 130, '2014' => 130, '2015' => 130},
            last_historical_year: 2010
          },
          @czechia.id => {
            emissions: {'2013' => 140, '2014' => 140, '2015' => 140},
            last_historical_year: 2010
          }
        },
        metadata: {unit: 'MtCO2e'}
      )
    end
  end
end
