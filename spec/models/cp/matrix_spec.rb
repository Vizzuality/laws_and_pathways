require 'rails_helper'

RSpec.describe CP::Matrix, type: :model do
  let_it_be(:cp_assessment) { create(:cp_assessment) }

  subject { build(:cp_matrix, cp_assessment: cp_assessment) }

  it { is_expected.to be_valid }

  it 'should be invalid if cp_assessment is nil' do
    subject.cp_assessment = nil
    expect(subject).to have(1).errors_on(:cp_assessment)
  end

  it 'should be invalid if portfolio is nil' do
    subject.portfolio = nil
    expect(subject).to have(1).errors_on(:portfolio)
  end

  it 'should be invalid if portfolio is not in the list' do
    subject.portfolio = 'WRONG'
    expect(subject).to have(1).errors_on(:portfolio)
  end

  it 'should be invalid if cp_alignment_2025 is not in the list' do
    subject.cp_alignment_2025 = 'WRONG'
    expect(subject).to have(1).errors_on(:cp_alignment_2025)
  end

  it 'should be invalid if cp_alignment_2035 is not in the list' do
    subject.cp_alignment_2035 = 'WRONG'
    expect(subject).to have(1).errors_on(:cp_alignment_2035)
  end

  it 'should be invalid if cp_alignment_2050 is not in the list' do
    subject.cp_alignment_2050 = 'WRONG'
    expect(subject).to have(1).errors_on(:cp_alignment_2050)
  end
end
