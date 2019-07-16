require 'rails_helper'

RSpec.describe Legislation, type: :model do
  subject { build(:legislation) }

  it { is_expected.to be_valid }

  it 'should be invalid without location' do
    subject.location = nil
    expect(subject).to have(1).errors_on(:location)
  end

  it 'should be invalid if title is nil' do
    subject.title = nil
    expect(subject).to have(1).errors_on(:title)
  end

  it 'should be invalid if framework is nil' do
    subject.framework = nil
    expect(subject).to have(1).errors_on(:framework)
  end
end
