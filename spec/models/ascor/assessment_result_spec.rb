# == Schema Information
#
# Table name: ascor_assessment_results
#
#  id            :bigint           not null, primary key
#  assessment_id :bigint           not null
#  indicator_id  :bigint           not null
#  answer        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  source        :string
#  year          :integer
#
require 'rails_helper'

RSpec.describe ASCOR::AssessmentResult, type: :model do
  subject { build(:ascor_assessment_result) }

  it { is_expected.to be_valid }

  it 'should be invalid without assessment' do
    subject.assessment = nil
    expect(subject).to have(1).errors_on(:assessment)
  end

  it 'should be invalid without indicator' do
    subject.indicator = nil
    expect(subject).to have(1).errors_on(:indicator)
  end

  it 'should be invalid when result already exists for assessment and indicator' do
    result = create :ascor_assessment_result
    subject.assessment = result.assessment
    subject.indicator = result.indicator
    expect(subject).to have(1).errors_on(:indicator_id)
  end
end
