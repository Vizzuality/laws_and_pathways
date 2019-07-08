# == Schema Information
#
# Table name: mq_assessments
#
#  id               :bigint(8)        not null, primary key
#  company_id       :bigint(8)
#  level            :string           not null
#  notes            :text
#  assessment_date  :date             not null
#  publication_date :date             not null
#  questions        :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe MQ::Assessment, type: :model do
  subject { build(:mq_assessment) }

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
end
