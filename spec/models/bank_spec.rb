# == Schema Information
#
# Table name: banks
#
#  id                 :bigint           not null, primary key
#  geography_id       :bigint
#  name               :string           not null
#  slug               :string           not null
#  isin               :string           not null
#  sedol              :string
#  market_cap_group   :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  latest_information :text
#
require 'rails_helper'

RSpec.describe Bank, type: :model do
  subject { build(:bank) }

  it { is_expected.to be_valid }

  it 'should be invalid without geography' do
    subject.geography = nil
    expect(subject).to have(1).errors_on(:geography)
  end

  it 'should be invalid if name is nil' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if isin is nil' do
    subject.isin = nil
    expect(subject).to have(1).errors_on(:isin)
  end

  it 'should be invalid if name is taken' do
    create(:bank, name: 'ACME')
    subject.name = 'ACME'
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should update slug when editing name' do
    bank = create(:bank, name: 'Some name')
    expect(bank.slug).to eq('some-name')
    bank.update!(name: 'New name')
    expect(bank.slug).to eq('new-name')
  end
end
