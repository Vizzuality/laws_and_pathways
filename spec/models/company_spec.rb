# == Schema Information
#
# Table name: companies
#
#  id                        :bigint           not null, primary key
#  geography_id              :bigint
#  headquarters_geography_id :bigint
#  sector_id                 :bigint
#  name                      :string           not null
#  slug                      :string           not null
#  isin                      :string           not null
#  size                      :string
#  ca100                     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  discarded_at              :datetime
#

require 'rails_helper'

RSpec.describe Company, type: :model do
  subject { build(:company) }

  it { is_expected.to be_valid }

  it 'should be invalid without geography' do
    subject.geography = nil
    expect(subject).to have(1).errors_on(:geography)
  end

  it 'should be invalid without headquarters geography' do
    subject.headquarters_geography = nil
    expect(subject).to have(1).errors_on(:headquarters_geography)
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

  it 'should be invalid if name is taken' do
    create(:company, name: 'ACME')
    subject.name = 'ACME'
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(2).errors_on(:visibility_status)
  end
end
