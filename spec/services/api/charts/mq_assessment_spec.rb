require 'rails_helper'

RSpec.describe Api::Charts::MQAssessment do
  describe '.assessments_levels_data' do
    context 'when company has several MQ assessments over last years' do
      let(:company) { create(:company) }

      before do
        create(:mq_assessment, company: company, assessment_date: '2016-01-01', level: '1')
        create(:mq_assessment, company: company, assessment_date: '2017-01-01', level: '2')
        create(:mq_assessment, company: company, assessment_date: '2018-01-01', level: '3')
        create(:mq_assessment, company: company, assessment_date: '2018-08-08', level: '2')
        create(:mq_assessment, company: company, assessment_date: '2019-02-02', level: '4')
        create(:mq_assessment, company: company, assessment_date: '2020-03-03', level: '3')
      end

      describe 'displaying for latest assessment' do
        subject { described_class.new(company.latest_mq_assessment) }

        it 'returns [year, level] pairs from begining of first year to present year' do
          Timecop.freeze(Time.local(2020, 5, 5)) do
            expect(subject.assessments_levels_data)
              .to eq([
                       ['2016-01-01', nil],
                       %w[2016-01-01 1],
                       %w[2017-01-01 2],
                       %w[2018-01-01 3],
                       %w[2018-08-08 2],
                       %w[2019-02-02 4],
                       %w[2020-03-03 3],
                       ['2020-05-05', nil]
                     ])
          end
        end
      end

      describe 'displaying for historic assessment' do
        subject { described_class.new(company.mq_assessments.where(assessment_date: '2018-08-08').first) }

        it 'returns [year, level] pairs from begining of first year to present year' do
          Timecop.freeze(Time.local(2020, 5, 5)) do
            expect(subject.assessments_levels_data)
              .to eq([
                       ['2016-01-01', nil],
                       %w[2016-01-01 1],
                       %w[2017-01-01 2],
                       %w[2018-01-01 3],
                       %w[2018-08-08 2],
                       ['2020-05-05', nil]
                     ])
          end
        end
      end
    end

    context 'when company has single MQ assessment from last year' do
      subject { described_class.new(company.latest_mq_assessment) }

      let(:company) { create(:company) }

      before do
        create(:mq_assessment, company: company, assessment_date: '2018-08-08', level: '2')
      end

      it 'returns [year, level] pairs from begining of first year to present year' do
        Timecop.freeze(Time.local(2019, 11, 3)) do
          expect(subject.assessments_levels_data)
            .to eq([
                     ['2018-01-01', nil],
                     %w[2018-08-08 2],
                     ['2019-11-03', nil]
                   ])
        end
      end
    end

    context 'when company does not have any MQ assessment' do
      subject { described_class.new(company_no_mq.latest_mq_assessment) }

      let(:company_no_mq) { create(:company) }

      it 'returns empty array' do
        expect(subject.assessments_levels_data).to eq([])
      end
    end
  end
end
