require 'rails_helper'

RSpec.describe ASCOR::Pathway, type: :model do
  subject { build(:ascor_pathway) }

  it { is_expected.to be_valid }

  it 'should be invalid without country' do
    subject.country = nil
    expect(subject).to have(1).errors_on(:country)
  end

  it 'should be invalid without emissions_metric' do
    subject.emissions_metric = nil
    expect(subject).to have(1).errors_on(:emissions_metric)
  end

  it 'should be invalid without emissions_boundary' do
    subject.emissions_boundary = nil
    expect(subject).to have(1).errors_on(:emissions_boundary)
  end

  it 'should be invalid without units' do
    subject.units = nil
    expect(subject).to have(1).errors_on(:units)
  end

  it 'should be invalid without assessment_date' do
    subject.assessment_date = nil
    expect(subject).to have(1).errors_on(:assessment_date)
  end

  it 'should be invalid if emissions_metric is not in METRICS' do
    subject.emissions_metric = 'TEST'
    expect(subject).to have(1).errors_on(:emissions_metric)
  end

  it 'should be invalid if emissions_boundary is not in BOUNDARIES' do
    subject.emissions_boundary = 'TEST'
    expect(subject).to have(1).errors_on(:emissions_boundary)
  end
end
