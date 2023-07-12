# == Schema Information
#
# Table name: bank_assessment_results
#
#  id                           :bigint           not null, primary key
#  bank_assessment_id           :bigint
#  bank_assessment_indicator_id :bigint
#  answer                       :string
#  percentage                   :float
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
require 'rails_helper'

RSpec.describe BankAssessmentResult, type: :model do
  subject {
    build(
      :bank_assessment_result,
      indicator: create(:bank_assessment_indicator, indicator_type: 'sub_area')
    )
  }

  it { is_expected.to be_valid }

  describe 'for percentage indicator' do
    subject {
      build(
        :bank_assessment_result,
        percentage: 30,
        indicator: create(:bank_assessment_indicator, indicator_type: 'area')
      )
    }

    it { is_expected.to be_valid }

    it 'should be invalid without percentage' do
      subject.percentage = nil
      expect(subject).to have(1).errors_on(:percentage)
    end
  end

  describe 'for answer indicator' do
    subject {
      build(
        :bank_assessment_result,
        answer: 'Yes',
        indicator: create(:bank_assessment_indicator, indicator_type: 'sub_indicator')
      )
    }

    it { is_expected.to be_valid }

    it 'should be invalid without answer' do
      subject.answer = nil
      expect(subject).to have(1).errors_on(:answer)
    end

    it 'should be invalid with wrong answer' do
      subject.answer = 'Wrong'
      expect(subject).to have(1).errors_on(:answer)
    end
  end
end
