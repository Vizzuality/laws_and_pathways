# == Schema Information
#
# Table name: mq_assessments
#
#  id                  :bigint           not null, primary key
#  company_id          :bigint
#  level               :string           not null
#  notes               :text
#  assessment_date     :date             not null
#  publication_date    :date             not null
#  questions           :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  discarded_at        :datetime
#  methodology_version :integer
#

require 'rails_helper'

RSpec.describe MQ::Assessment, type: :model do
  subject { build(:mq_assessment) }

  let(:company) { create(:company) }

  it { is_expected.to be_valid }

  it 'should be invalid if publication date is nil' do
    subject.publication_date = nil
    expect(subject).to have(1).errors_on(:publication_date)
  end

  it 'should be invalid if level not recognized' do
    subject.level = '5'
    expect(subject).to have(1).errors_on(:level)
  end

  it 'should be invalid if assessment date is nil' do
    subject.assessment_date = nil
    expect(subject).to have(1).errors_on(:assessment_date)
  end

  it 'should be invalid if assessment date is before 2010' do
    subject.assessment_date = '2001-02-15'
    expect(subject).to have(1).errors_on(:assessment_date)
  end

  it 'should be invalid if publication date is before 2010' do
    subject.publication_date = '2001-02-15'
    expect(subject).to have(1).errors_on(:publication_date)
  end

  describe 'previous' do
    it 'should return previous assessment for the same company' do
      assessments = [
        create(:mq_assessment, company: company, assessment_date: 12.months.ago),
        create(:mq_assessment, company: company, assessment_date: 4.months.ago),
        create(:mq_assessment, company: company, assessment_date: 2.months.ago),
        create(:mq_assessment, company: company, assessment_date: 1.month.ago)
      ]

      expect(assessments[1].previous).to eq(assessments[0])
      expect(assessments[2].previous).to eq(assessments[1])
    end
  end

  describe 'status' do
    it 'should be new if first assessment' do
      assessment = create(:mq_assessment, company: company)
      expect(assessment.status).to eq('new')
    end

    it 'should be up if level higher than in the previous asssessment' do
      create(:mq_assessment, company: company, assessment_date: 12.months.ago, level: '2')
      current = create(:mq_assessment, company: company, assessment_date: 6.months.ago, level: '3')
      expect(current.status).to eq('up')
    end

    it 'should be down if level lower than in the previous assessment' do
      create(:mq_assessment, company: company, assessment_date: 12.months.ago, level: '3')
      current = create(:mq_assessment, company: company, assessment_date: 6.months.ago, level: '2')
      expect(current.status).to eq('down')
    end

    it 'should be unchanged if level the same as in the previous assessment' do
      create(:mq_assessment, company: company, assessment_date: 12.months.ago, level: '3')
      current = create(:mq_assessment, company: company, assessment_date: 6.months.ago, level: '3')
      expect(current.status).to eq('unchanged')
    end
  end
end
