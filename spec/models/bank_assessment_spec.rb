require 'rails_helper'

RSpec.describe BankAssessment, type: :model do
  subject { build(:bank_assessment, bank: build(:bank)) }

  it { is_expected.to be_valid }

  it 'should be invalid if assessment date is nil' do
    subject.assessment_date = nil
    expect(subject).to have(1).errors_on(:assessment_date)
  end

  it 'should be invalid without bank' do
    subject.bank = nil
    expect(subject).to have(1).errors_on(:bank)
  end
end
