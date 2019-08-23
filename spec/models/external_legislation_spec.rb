# == Schema Information
#
# Table name: external_legislations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  url          :string
#  geography_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe ExternalLegislation, type: :model do
  subject { build(:external_legislation) }

  it { is_expected.to be_valid }

  it 'should be valid without URL' do
    subject.url = nil
    expect(subject).to have(0).errors
  end

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid with invalid URL format' do
    subject.url = 'no_schema'
    expect(subject).to have(1).errors_on(:url)
  end

  it 'should be invalid without geography' do
    subject.geography = nil
    expect(subject).to have(1).errors_on(:geography)
  end
end
