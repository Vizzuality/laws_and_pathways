require 'rails_helper'

RSpec.describe Api::ASCOR::BenchmarksChart do
  subject { described_class.new(assessment_date, country_id).call }

  before_all do
    @country = create :ascor_country
    _draft_country = create(:ascor_country, id: 30, name: 'Draft Country', iso: 'DFT')

    create :ascor_pathway,
           country: @country,
           assessment_date: Date.new(2019, 2, 1),
           emissions_metric: 'Absolute',
           emissions_boundary: 'Production - excluding LULUCF',
           emissions: {2013 => 130, 2014 => 130, 2015 => 130}
    create :ascor_benchmark,
           country: @country,
           emissions_metric: 'Absolute',
           emissions_boundary: 'Production - excluding LULUCF',
           emissions: {2015 => 10, 2016 => 11, 2017 => 12}
  end

  let(:assessment_date) { Date.new(2019, 2, 1) }
  let(:country_id) { @country.id }

  it 'returns expected result' do
    expect(subject).to eq(
      data: {
        emissions: {'2013' => 130, '2014' => 130, '2015' => 130},
        last_historical_year: 2010,
        benchmarks: [
          {benchmark_type: 'National 1.5C benchmark', emissions: {'2015' => 10, '2016' => 11, '2017' => 12}}
        ]
      },
      metadata: {unit: 'MtCO2e'}
    )
  end
end
