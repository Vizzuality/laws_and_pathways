require 'rails_helper'

RSpec.describe ASCOR::Country, type: :model do
  subject { build(:ascor_country) }

  it { is_expected.to be_valid }

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid without iso' do
    subject.iso = nil
    expect(subject).to have(1).errors_on(:iso)
  end

  it 'should be invalid without region' do
    subject.region = nil
    expect(subject).to have(1).errors_on(:region)
  end

  it 'should be invalid without wb_lending_group' do
    subject.wb_lending_group = nil
    expect(subject).to have(1).errors_on(:wb_lending_group)
  end

  it 'should be invalid without fiscal_monitor_category' do
    subject.fiscal_monitor_category = nil
    expect(subject).to have(1).errors_on(:fiscal_monitor_category)
  end

  it 'should be invalid if name is taken' do
    create(:ascor_country, name: 'TEST')
    subject.name = 'TEST'
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if iso is taken' do
    create(:ascor_country, iso: 'TEST')
    subject.iso = 'TEST'
    expect(subject).to have(1).errors_on(:iso)
  end

  it 'should be invalid if wb_lending_group is not in LENDING_GROUPS' do
    subject.wb_lending_group = 'TEST'
    expect(subject).to have(1).errors_on(:wb_lending_group)
  end

  it 'should be invalid if fiscal_monitor_category is not in MONITOR_CATEGORIES' do
    subject.fiscal_monitor_category = 'TEST'
    expect(subject).to have(1).errors_on(:fiscal_monitor_category)
  end

  it 'should be invalid if type_of_party is not in TYPES_OF_PARTY' do
    subject.type_of_party = 'TEST'
    expect(subject).to have(1).errors_on(:type_of_party)
  end
end
