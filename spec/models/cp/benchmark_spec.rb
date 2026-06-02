# == Schema Information
#
# Table name: cp_benchmarks
#
#  id           :bigint           not null, primary key
#  sector_id    :bigint
#  release_date :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  emissions    :jsonb
#  scenario     :string
#  region       :string           default("Global"), not null
#  category     :string           not null
#

require 'rails_helper'

RSpec.describe CP::Benchmark, type: :model do
  subject { build(:cp_benchmark) }

  it { is_expected.to be_valid }

  it 'should be invalid without sector' do
    subject.sector = nil
    expect(subject).to have(1).errors_on(:sector)
  end

  it 'should be invalid if date is nil' do
    subject.release_date = nil
    expect(subject).to have(1).errors_on(:release_date)
  end

  it 'should be invalid if region is unknown' do
    subject.region = 'unknown'
    expect(subject).to have(1).errors_on(:region)
  end

  it 'should be invalid without category' do
    subject.category = nil
    expect(subject).to have(1).errors_on(:category)
  end

  describe '.exportable_for_sector_download' do
    let(:chemicals_sector) { create(:tpi_sector, name: 'Chemicals') }
    let(:steel_sector) { create(:tpi_sector, name: 'Steel') }

    it 'includes all benchmarks from non-Chemicals sectors' do
      steel_benchmark = create(:cp_benchmark, sector: steel_sector, subsector: 'Primary Steel')
      result = described_class.exportable_for_sector_download
      expect(result).to include(steel_benchmark)
    end

    it 'includes Chemicals benchmarks with standard subsectors (lowercase)' do
      primary = create(:cp_benchmark, sector: chemicals_sector, subsector: 'primary chemicals')
      result = described_class.exportable_for_sector_download
      expect(result).to include(primary)
    end

    it 'includes Chemicals benchmarks with standard subsectors (mixed case)' do
      primary = create(:cp_benchmark, sector: chemicals_sector, subsector: 'Primary Chemicals')
      result = described_class.exportable_for_sector_download
      expect(result).to include(primary)
    end

    it 'includes Chemicals benchmarks with standard subsectors (title case)' do
      non_primary = create(:cp_benchmark, sector: chemicals_sector, subsector: 'Non-Primary Chemicals')
      result = described_class.exportable_for_sector_download
      expect(result).to include(non_primary)
    end

    it 'excludes Chemicals benchmarks with company-specific subsectors' do
      basf = create(:cp_benchmark, sector: chemicals_sector, subsector: 'BASF')
      result = described_class.exportable_for_sector_download
      expect(result).not_to include(basf)
    end

    it 'excludes Chemicals benchmarks with company-specific subsectors (mixed case)' do
      dow = create(:cp_benchmark, sector: chemicals_sector, subsector: 'Dow Chemical')
      result = described_class.exportable_for_sector_download
      expect(result).not_to include(dow)
    end

    it 'includes Chemicals benchmarks with NULL subsector' do
      legacy = create(:cp_benchmark, sector: chemicals_sector, subsector: nil)
      result = described_class.exportable_for_sector_download
      expect(result).to include(legacy)
    end

    it 'handles all three standard subsector variants' do
      primary = create(:cp_benchmark, sector: chemicals_sector, subsector: 'Primary chemicals')
      non_primary = create(:cp_benchmark, sector: chemicals_sector, subsector: 'Non-Primary Chemicals')
      agricultural = create(:cp_benchmark, sector: chemicals_sector, subsector: 'AGRICULTURAL CHEMICALS')

      result = described_class.exportable_for_sector_download
      expect(result).to include(primary, non_primary, agricultural)
    end
  end
end
