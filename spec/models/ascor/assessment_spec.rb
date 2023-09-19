require 'rails_helper'

RSpec.describe ASCOR::Assessment, type: :model do
  subject { build(:ascor_assessment) }

  it { is_expected.to be_valid }

  it 'should be invalid without assessment_date' do
    subject.assessment_date = nil
    expect(subject).to have(1).errors_on(:assessment_date)
  end
end
