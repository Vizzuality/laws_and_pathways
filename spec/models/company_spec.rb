# == Schema Information
#
# Table name: companies
#
#  id                        :bigint           not null, primary key
#  geography_id              :bigint
#  headquarters_geography_id :bigint
#  sector_id                 :bigint
#  name                      :string           not null
#  slug                      :string           not null
#  isin                      :string           not null
#  market_cap_group          :string
#  ca100                     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  discarded_at              :datetime
#  sedol                     :string
#  latest_information        :text
#  historical_comments       :text
#

require 'rails_helper'

RSpec.describe Company, type: :model do
  subject { build(:company) }

  it { is_expected.to be_valid }

  it 'should be invalid without geography' do
    subject.geography = nil
    expect(subject).to have(1).errors_on(:geography)
  end

  it 'should be invalid without headquarters geography' do
    subject.headquarters_geography = nil
    expect(subject).to have(1).errors_on(:headquarters_geography)
  end

  it 'should be invalid if name is nil' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if isin is nil' do
    subject.isin = nil
    expect(subject).to have(1).errors_on(:isin)
  end

  it 'should be invalid if name is taken' do
    create(:company, name: 'ACME')
    subject.name = 'ACME'
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(2).errors_on(:visibility_status)
  end

  describe '#latest_cp_assessment' do
    it 'returns last CP assessments with most recent assessment date' do
      company = create(:company, cp_assessments: [
                         create(:cp_assessment, assessment_date: '2012-05-01'),
                         create(:cp_assessment, assessment_date: '2019-05-01'),
                         create(:cp_assessment, assessment_date: '2013-05-01'),
                         create(:cp_assessment, assessment_date: '2018-05-01')
                       ])

      expect(company.latest_cp_assessment.assessment_date.to_s).to eq('01/05/2019')
    end
  end

  describe '#latest_mq_assessment' do
    it 'returns last MQ assessments with most recent assessment date' do
      company = create(:company, mq_assessments: [
                         create(:mq_assessment, assessment_date: '2012-05-01'),
                         create(:mq_assessment, assessment_date: '2019-05-01'),
                         create(:mq_assessment, assessment_date: '2013-05-01'),
                         create(:mq_assessment, assessment_date: '2018-05-01')
                       ])

      expect(company.latest_mq_assessment.assessment_date.to_s).to eq('01/05/2019')
    end
  end

  describe '#latest_sector_benchmarks_before_last_assessment' do
    let(:sector_cp_benchmarks) do
      [
        create(:cp_benchmark, release_date: '2013-05-01', scenario: 'Below 2'),    # previous benchmarks
        create(:cp_benchmark, release_date: '2013-05-01', scenario: 'Paris'),      # - should be ignored
        create(:cp_benchmark, release_date: '2013-05-01', scenario: '2 degrees'),

        create(:cp_benchmark, release_date: '2016-05-01', scenario: 'Below 2'),    # last benchmarks
        create(:cp_benchmark, release_date: '2016-05-01', scenario: 'Paris'),      # before latest CP assessment
        create(:cp_benchmark, release_date: '2016-05-01', scenario: '2 degrees'),  # - OK

        create(:cp_benchmark, release_date: '2019-05-01', scenario: 'Below 2'),    # most recent benchmarks,
        create(:cp_benchmark, release_date: '2019-05-01', scenario: 'Paris'),      # but without CP assessment
        create(:cp_benchmark, release_date: '2019-05-01', scenario: '2 degrees')   # - should be ignored
      ]
    end
    let(:company_assessments) do
      [
        create(:cp_assessment, assessment_date: '2012-05-01', publication_date: '2012-05-01'),
        create(:cp_assessment, assessment_date: '2013-05-01', publication_date: '2013-05-01'),
        create(:cp_assessment, assessment_date: '2018-05-01', publication_date: '2018-05-01') # <- last assessment date
      ]
    end
    let(:older_company_assessments) do
      [
        create(:cp_assessment, assessment_date: '2011-05-01', publication_date: '2011-05-01'),
        create(:cp_assessment, assessment_date: '2012-05-01', publication_date: '2012-05-01')
      ]
    end

    it 'returns latest CP benchmarks with release date smaller than latest CP Assessment assessment date' do
      company = create(:company,
                       sector: create(:tpi_sector, cp_benchmarks: sector_cp_benchmarks),
                       cp_assessments: company_assessments)

      # last assessment year is 2018, so we should take benchmarks from 2016
      expect(company.latest_sector_benchmarks_before_last_assessment.pluck(:release_date, :scenario))
        .to eq([
                 [Date.parse('2016-05-01'), 'Below 2'],
                 [Date.parse('2016-05-01'), 'Paris'],
                 [Date.parse('2016-05-01'), '2 degrees']
               ])
    end

    it 'returns latest CP benchmarks with last release date if all CP Assessments are older' do
      company = create(:company,
                       sector: create(:tpi_sector, cp_benchmarks: sector_cp_benchmarks),
                       cp_assessments: older_company_assessments)

      # last assessment year is 2012 - before oldest bechmark, so we just take most recent benchmark
      expect(company.latest_sector_benchmarks_before_last_assessment.pluck(:release_date, :scenario))
        .to eq([
                 [Date.parse('2019-05-01'), 'Below 2'],
                 [Date.parse('2019-05-01'), 'Paris'],
                 [Date.parse('2019-05-01'), '2 degrees']
               ])
    end
  end
end
