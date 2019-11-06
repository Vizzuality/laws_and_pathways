require 'rails_helper'

RSpec.describe Api::Charts::CPAssessment do
  describe '.emissions_data' do
    let(:sector_a) { create(:tpi_sector, name: 'Sector A') }
    let(:sector_b) { create(:tpi_sector, name: 'Sector B') }
    let(:company_sector_a_1) { create(:company, sector: sector_a) }
    let(:company_sector_a_2) { create(:company, sector: sector_a) }

    let(:company_sector_b_1) { create(:company, sector: sector_b) }

    context 'when CP assessment is not nil' do
      let(:first_cp_assessment) {
        create(:cp_assessment,
               assessment_date: 10.months.ago,
               publication_date: 10.months.ago,
               company: company_sector_a_1,
               emissions: {'2017' => 90.0, '2018' => 90.0, '2019' => 110.0})
      }
      let(:last_cp_assessment) {
        create(:cp_assessment,
               assessment_date: 3.months.ago,
               publication_date: 3.months.ago,
               company: company_sector_a_2,
               emissions: {'2017' => 40.0, '2018' => 50.0})
      }

      before do
        # Sector B - should be ignored
        create(:cp_assessment,
               company: company_sector_b_1,
               emissions: {'2015' => 400.0, '2016' => 500.0})
        # Sector A
        create(:cp_benchmark,
               scenario: 'scenario',
               release_date: 5.months.ago,
               sector: sector_a,
               emissions: {'2018' => 124.0, '2017' => 122.0, '2016' => 115.5})
      end

      context 'for last assessment' do
        subject { described_class.new(last_cp_assessment) }

        it 'returns emissions data from: company, sector avg & sector benchmarks' do
          expect(subject.emissions_data).to eq [
            # company
            {
              name: company_sector_a_1.name,
              data: {'2017' => 90.0, '2018' => 90.0, '2019' => 110.0}
            },
            # sector average
            {
              name: "#{sector_a.name} sector mean",
              data: {'2017' => 65.0, '2018' => 70.0, '2019' => 110.0}
            },
            # CP benchmarks
            {
              type: 'area',
              fillOpacity: 0.1,
              name: 'scenario',
              data: {'2016' => 115.5, '2017' => 122.0, '2018' => 124.0}
            }
          ]
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

  # describe '.assessments_levels_data' do
  #   context 'when company has several MQ assessments over last years' do
  #     subject { described_class.new(company) }

  #     let(:company) { create(:company) }

  #     before do
  #       create(:mq_assessment, company: company, assessment_date: '2016-01-01', level: '1')
  #       create(:mq_assessment, company: company, assessment_date: '2017-01-01', level: '2')
  #       create(:mq_assessment, company: company, assessment_date: '2018-01-01', level: '3')
  #       create(:mq_assessment, company: company, assessment_date: '2018-08-08', level: '2')
  #       create(:mq_assessment, company: company, assessment_date: '2019-02-02', level: '4')
  #       create(:mq_assessment, company: company, assessment_date: '2020-03-03', level: '3')
  #     end

  #     it 'returns [year, level] pairs from begining of first year to present year' do
  #       Timecop.freeze(Time.local(2020, 5, 5)) do
  #         expect(subject.assessments_levels_data)
  #           .to eq([
  #                    ['2016-01-01', nil],
  #                    %w[2016-01-01 1],
  #                    %w[2017-01-01 2],
  #                    %w[2018-01-01 3],
  #                    %w[2018-08-08 2],
  #                    %w[2019-02-02 4],
  #                    %w[2020-03-03 3],
  #                    ['2020-05-05', nil]
  #                  ])
  #       end
  #     end
  #   end

  #   context 'when company has single MQ assessment from last year' do
  #     subject { described_class.new(company) }

  #     let(:company) { create(:company) }

  #     before do
  #       create(:mq_assessment, company: company, assessment_date: '2018-08-08', level: '2')
  #     end

  #     it 'returns [year, level] pairs from begining of first year to present year' do
  #       Timecop.freeze(Time.local(2019, 11, 3)) do
  #         expect(subject.assessments_levels_data)
  #           .to eq([
  #                    ['2018-01-01', nil],
  #                    %w[2018-08-08 2],
  #                    ['2019-11-03', nil]
  #                  ])
  #       end
  #     end
  #   end

  #   context 'when company does not have any MQ assessment' do
  #     subject { described_class.new(company_no_mq) }

  #     let(:company_no_mq) { create(:company) }

  #     it 'returns empty array' do
  #       expect(subject.assessments_levels_data).to eq([])
  #     end
  #   end
  # end
end
