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
#  company_comments_internal :text
#  active                    :boolean          default(TRUE)
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

  it 'should update slug when editing name' do
    company = create(:company, name: 'Some name')
    expect(company.slug).to eq('some-name')
    company.update!(name: 'New name')
    expect(company.slug).to eq('new-name')
  end

  describe '#latest_cp_assessment' do
    it 'returns last CP assessments with most recent assessment date' do
      company = create(:company, cp_assessments: [
                         build(:cp_assessment, assessment_date: '2012-05-01'),
                         build(:cp_assessment, assessment_date: '2019-05-01'),
                         build(:cp_assessment, assessment_date: '2013-05-01'),
                         build(:cp_assessment, assessment_date: '2020-01-01', publication_date: 1.year.from_now)
                       ])

      expect(company.latest_cp_assessment.assessment_date.to_s).to eq('01/05/2019')
    end
  end

  describe '#latest_mq_assessment' do
    it 'returns last MQ assessments with most recent assessment date' do
      company = create(:company, mq_assessments: [
                         build(:mq_assessment, assessment_date: '2012-05-01'),
                         build(:mq_assessment, assessment_date: '2019-05-01'),
                         build(:mq_assessment, assessment_date: '2013-05-01'),
                         build(:mq_assessment, assessment_date: '2018-05-01'),
                         build(:mq_assessment, assessment_date: '2020-01-01', publication_date: 1.year.from_now)
                       ])

      expect(company.latest_mq_assessment.assessment_date.to_s).to eq('01/05/2019')
    end
  end
end
