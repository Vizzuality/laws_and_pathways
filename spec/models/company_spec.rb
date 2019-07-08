# == Schema Information
#
# Table name: companies
#
#  id                      :bigint(8)        not null, primary key
#  location_id             :bigint(8)
#  headquarter_location_id :bigint(8)
#  sector_id               :bigint(8)
#  name                    :string           not null
#  slug                    :string           not null
#  isin                    :string           not null
#  size                    :string
#  ca100                   :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'rails_helper'

RSpec.describe Company, type: :model do
  subject { build(:company) }

  it { is_expected.to be_valid }

  it 'should be invalid without location' do
    subject.location = nil
    expect(subject).to have(1).errors_on(:location)
  end

  it 'should be invalid without headquarter location' do
    subject.headquarter_location = nil
    expect(subject).to have(1).errors_on(:headquarter_location)
  end

  it 'should be invalid if name is nil' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if isin is nil' do
    subject.isin = nil
    expect(subject).to have(1).errors_on(:isin)
  end

  it 'should be invalid if isin is taken' do
    create(:company, isin: 'ISIN123')
    subject.isin = 'ISIN123'
    expect(subject).to have(1).errors_on(:isin)
  end
end
