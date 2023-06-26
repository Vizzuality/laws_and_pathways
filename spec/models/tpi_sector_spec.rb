# == Schema Information
#
# Table name: tpi_sectors
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  slug             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cluster_id       :bigint
#  show_in_tpi_tool :boolean          default(TRUE), not null
#  categories       :string           default([]), is an Array
#

require 'rails_helper'

RSpec.describe TPISector, type: :model do
  subject { build(:tpi_sector) }

  it { is_expected.to be_valid }

  it 'should not be valid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should not be valid if name taken' do
    create(:tpi_sector, name: 'Airlines')
    expect(build(:tpi_sector, name: 'Airlines')).to have(1).errors_on(:name)
  end

  it 'should not be valid when category is unknown' do
    subject.categories = ['Unknown']
    expect(subject).to have(1).errors_on(:categories)
  end

  it 'should update slug when editing name' do
    sector = create(:tpi_sector, name: 'Some name')
    expect(sector.slug).to eq('some-name')
    sector.update!(name: 'New name')
    expect(sector.slug).to eq('new-name')
  end

  describe '#cp_unit_valid_for_date' do
    let(:sector) { create(:tpi_sector) }
    let(:sector2) { create(:tpi_sector) }
    let!(:first_unit) { create(:cp_unit, sector: sector, unit: 'first', valid_since: nil) }
    let!(:second_unit) { create(:cp_unit, sector: sector, unit: 'second', valid_since: 5.months.ago) }
    let!(:third_unit) { create(:cp_unit, sector: sector, unit: 'third', valid_since: 3.months.ago) }

    it 'should return valid date based on date' do
      expect(sector.cp_unit_valid_for_date(10.months.ago)).to eq(first_unit)
      expect(sector.cp_unit_valid_for_date(4.months.ago)).to eq(second_unit)
      expect(sector.cp_unit_valid_for_date(2.months.ago)).to eq(third_unit)
    end

    it 'should return latest if date not provided' do
      expect(sector.cp_unit_valid_for_date(nil)).to eq(third_unit)
    end

    it 'should return nil if no units' do
      expect(sector2.cp_unit_valid_for_date(10.months.ago)).to be_nil
    end
  end

  describe '#latest_benchmarks_for_date' do
    let(:sector) { create(:tpi_sector) }
    let!(:first_benchmark) {
      create(:cp_benchmark, sector: sector, category: Company.to_s, scenario: 'scenario', release_date: 12.months.ago)
    }
    let!(:second_benchmark) {
      create(:cp_benchmark, sector: sector, category: Company.to_s, scenario: 'scenario', release_date: 5.months.ago)
    }

    it 'should return first benchmark if is the latest one to the date' do
      expect(sector.latest_benchmarks_for_date(10.months.ago, category: Company.to_s)).to eq([first_benchmark])
    end

    it 'should return last benchmark if is the latest one to the date' do
      expect(sector.latest_benchmarks_for_date(3.months.ago, category: Company.to_s)).to eq([second_benchmark])
    end

    it 'should return the latest if no date given' do
      expect(sector.latest_benchmarks_for_date(nil, category: Company.to_s)).to eq([second_benchmark])
    end
  end
end
