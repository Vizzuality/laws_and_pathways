require 'rails_helper'

RSpec.describe Api::Charts::CPAssessment do
  describe '.emissions_data' do
    let(:sector_a) { create(:tpi_sector, name: 'Sector A') }
    let(:sector_b) { create(:tpi_sector, name: 'Sector B') }
    let(:company_sector_a_1) { create(:company, sector: sector_a) }
    let(:company_sector_a_2) { create(:company, sector: sector_a) }

    let(:company_sector_b_1) { create(:company, sector: sector_b) }

    context 'when CP assessment is not nil' do
      before do
        # Sector B - should be ignored
        create(:cp_assessment,
               company: company_sector_b_1,
               emissions: {'2015' => 400.0, '2016' => 500.0})
        # Sector A
        create(:cp_benchmark,
               scenario: 'scenario',
               release_date: 12.months.ago,
               sector: sector_a,
               emissions: {'2016' => 130.0, '2017' => 120.0, '2018' => 100.0})
        create(:cp_benchmark,
               scenario: 'scenario',
               release_date: 7.months.ago,
               sector: sector_a,
               emissions: {'2016' => 115.5, '2017' => 122.0, '2018' => 124.0})

        # create some assessment for sector A
        create(:cp_assessment,
               assessment_date: 10.months.ago,
               publication_date: 10.months.ago,
               last_reported_year: 2018,
               company: company_sector_a_1,
               emissions: {'2017' => 90.0, '2018' => 90.0, '2019' => 110.0})
        create(:cp_assessment,
               assessment_date: 6.months.ago,
               publication_date: 6.months.ago,
               last_reported_year: 2018,
               company: company_sector_a_1,
               emissions: {'2017' => 100.0, '2018' => 70.0, '2019' => 110.0})
        create(:cp_assessment,
               assessment_date: 11.months.ago,
               publication_date: 11.months.ago,
               last_reported_year: 2018,
               company: company_sector_a_2,
               emissions: {'2017' => 40.0, '2018' => 50.0})
      end

      context 'for last assessment' do
        subject { described_class.new(company_sector_a_1.latest_cp_assessment) }

        it 'returns emissions data from: company, sector avg & sector benchmarks' do
          company_sector_a_1_data = subject.emissions_data.find { |s| s[:name] == company_sector_a_1.name }[:data]
          sector_average_data = subject.emissions_data.find { |s| s[:name] == "#{sector_a.name} sector mean" }[:data]
          cp_benchmarks_data = subject.emissions_data.find { |s| s[:name] == 'scenario' }[:data]

          expect(company_sector_a_1_data).to eq(2017 => 100.0, 2018 => 70.0, 2019 => 110.0)
          # sector average_data is only up to last_reported_year
          expect(sector_average_data).to eq(2017 => (100.0 + 40.0) / 2, 2018 => (70.0 + 50.0) / 2)
          expect(cp_benchmarks_data).to eq(2016 => 115.5, 2017 => 122.0, 2018 => 124.0)
        end
      end

      context 'for first historic assessment' do
        subject { described_class.new(company_sector_a_1.cp_assessments.order(:assessment_date).first) }

        it 'returns emissions data from: company, sector avg & sector benchmarks' do
          company_sector_a_1_data = subject.emissions_data.find { |s| s[:name] == company_sector_a_1.name }[:data]
          sector_average_data = subject.emissions_data.find { |s| s[:name] == "#{sector_a.name} sector mean" }[:data]
          cp_benchmarks_data = subject.emissions_data.find { |s| s[:name] == 'scenario' }[:data]

          expect(company_sector_a_1_data).to eq(2017 => 90.0, 2018 => 90.0, 2019 => 110.0)
          # sector average_data is only up to last_reported_year
          expect(sector_average_data).to eq(2017 => (90.0 + 40.0) / 2, 2018 => (90.0 + 50.0) / 2)
          expect(cp_benchmarks_data).to eq(2016 => 130.0, 2017 => 120.0, 2018 => 100.0)
        end
      end
    end

    context 'when CP assessment is nil' do
      subject { described_class.new(nil) }

      it 'returns no emissions data' do
        expect(subject.emissions_data).to eq []
      end
    end
  end
end
