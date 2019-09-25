require 'rails_helper'

RSpec.describe Api::Charts::CPBenchmark do
  subject { described_class.new }
  let!(:sector) { create(:sector) }
  let!(:company) { create(:company, sector: sector) }
  let(:current_year) { '2018' }

  before do
    allow(subject)
      .to receive(:current_year)
      .and_return(current_year)
  end

  describe '.cp_performance' do
    context 'sector has no scenarios' do
      it 'returns empty list' do
        expect(subject.cp_performance).to eq([])
      end

      context 'sector has scenarios but company has no emissions' do
        let!(:cp_benchmark) { create(:cp_benchmark, sector: sector) }

        it 'returns empty list' do
          expect(subject.cp_performance).to eq([])
        end
      end

      context 'company has emissions' do
        let!(:scenario_1) { 'scenario_1' }
        let!(:scenario_2) { 'scenario_2' }
        before do
          create(
            :cp_benchmark,
            scenario: scenario_1,
            sector: sector,
            emissions: {"2018": 124.0, "2017": 122.0}
          )
          create(
            :cp_benchmark,
            scenario: scenario_2,
            sector: sector,
            emissions: {"2018": 110.0, "2017": 90.0}
          )
          create(
            :cp_assessment,
            company: company,
            assessment_date: '2019-02-01',
            emissions: {"2017": 90.0, "2018": 90.0, "2019": 110.0}
          )
          create(
            :cp_assessment,
            company: company,
            assessment_date: '2019-01-01',
            emissions: {"2017": 90.0, "2018": 120.0, "2019": 110.0}
          )
          create(
            :cp_assessment,
            company: create(:company, sector: sector),
            assessment_date: '2019-01-01',
            emissions: {"2016": 90.0, "2017": 120.0}
          )
        end

        it 'returns chart data' do
          expect(subject.cp_performance).to eq(
            [
              {
                name: scenario_2,
                data: [[sector.name, 1]]
              },
              {
                name: scenario_1,
                data: [[sector.name, 1]]
              }
            ]
          )
        end
      end
    end
  end
end
