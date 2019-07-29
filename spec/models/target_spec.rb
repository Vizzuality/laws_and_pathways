require 'rails_helper'

RSpec.describe Target, type: :model do
  subject { build(:target) }

  it { is_expected.to be_valid }

  it 'should not be valid without type' do
    subject.type = nil
    expect(subject).to have(1).errors_on(:type)
  end

  it 'should be invalid if ghg_target null' do
    subject.ghg_target = nil
    expect(subject).to have(1).errors_on(:ghg_target)
  end
end
