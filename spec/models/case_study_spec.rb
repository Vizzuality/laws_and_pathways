require 'rails_helper'

RSpec.describe CaseStudy, type: :model do
  subject { build(:case_study) }

  it { is_expected.to be_valid }

  it 'should be invalid without organization' do
    subject.organization = nil
    expect(subject).to have(1).errors_on(:organization)
  end

  it 'should be invalid without text' do
    subject.text = nil
    expect(subject).to have(1).errors_on(:text)
  end

  it 'should be invalid without link' do
    subject.link = nil
    expect(subject).to have(1).errors_on(:link)
  end

  it 'should be invalid with wrong link' do
    subject.link = 'wrong'
    expect(subject).to have(1).errors_on(:link)
  end
end
