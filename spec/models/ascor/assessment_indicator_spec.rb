require 'rails_helper'

RSpec.describe ASCOR::AssessmentIndicator, type: :model do
  subject { build(:ascor_assessment_indicator) }

  it { is_expected.to be_valid }

  it 'should be invalid without indicator_type' do
    subject.indicator_type = nil
    expect(subject).to have(1).errors_on(:indicator_type)
  end

  it 'should be invalid without code' do
    subject.code = nil
    expect(subject).to have(1).errors_on(:code)
  end

  it 'should be invalid without text' do
    subject.text = nil
    expect(subject).to have(1).errors_on(:text)
  end

  it 'should be invalid if indicator_type is not in INDICATOR_TYPES' do
    expect { subject.indicator_type = 'TEST' }.to raise_error(ArgumentError)
  end
end
