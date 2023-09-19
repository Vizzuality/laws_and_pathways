require 'rails_helper'

RSpec.describe ASCOR::Benchmark, type: :model do
  subject { build(:ascor_benchmark) }

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

  it 'should be invalid without land_use' do
    subject.land_use = nil
    expect(subject).to have(1).errors_on(:land_use)
  end

  it 'should be invalid without units' do
    subject.units = nil
    expect(subject).to have(1).errors_on(:units)
  end

  it 'should be invalid without benchmark_type' do
    subject.benchmark_type = nil
    expect(subject).to have(1).errors_on(:benchmark_type)
  end

  it 'should be invalid if emissions_metric is not in METRICS' do
    subject.emissions_metric = 'TEST'
    expect(subject).to have(1).errors_on(:emissions_metric)
  end

  it 'should be invalid if emissions_boundary is not in BOUNDARIES' do
    subject.emissions_boundary = 'TEST'
    expect(subject).to have(1).errors_on(:emissions_boundary)
  end

  it 'should be invalid if land_use is not in LAND_USES' do
    subject.land_use = 'TEST'
    expect(subject).to have(1).errors_on(:land_use)
  end
end
