require 'rails_helper'

RSpec.describe CSVExport::User::CPBenchmarks do
  let(:chemicals_sector) { create(:tpi_sector, name: 'Chemicals', categories: %w[Company]) }
  let(:steel_sector) { create(:tpi_sector, name: 'Steel', categories: %w[Company]) }
  let!(:primary_benchmark) do
    create(:cp_benchmark,
           sector: chemicals_sector,
           category: 'Company',
           scenario: '1.5 Degrees',
           subsector: 'Primary chemicals',
           release_date: Date.new(2026, 5, 10))
  end
  let!(:company_benchmark_subsector) do
    create(:cp_benchmark,
           sector: chemicals_sector,
           category: 'Company',
           scenario: '1.5 Degrees',
           subsector: 'BASF',
           benchmark_label: 'BASF',
           release_date: Date.new(2026, 5, 10))
  end
  let!(:company_benchmark_label_only) do
    create(:cp_benchmark,
           sector: chemicals_sector,
           category: 'Company',
           scenario: 'Below 2 Degrees',
           subsector: nil,
           benchmark_label: 'Company A',
           release_date: Date.new(2026, 5, 10))
  end
  let!(:steel_benchmark) do
    create(:cp_benchmark,
           sector: steel_sector,
           category: 'Company',
           scenario: 'Below 2 Degrees',
           subsector: 'BF-BOF',
           release_date: Date.new(2026, 5, 10))
  end

  subject { described_class.new(CP::Benchmark.all) }

  def parsed_rows
    CSV.parse(subject.call, headers: true)
  end

  def benchmark_ids
    parsed_rows['Benchmark ID']
  end

  it 'includes allowlisted Chemicals subsector benchmarks only' do
    expect(benchmark_ids).to include(primary_benchmark.benchmark_id)
    expect(benchmark_ids).not_to include(company_benchmark_subsector.benchmark_id)
    expect(benchmark_ids).not_to include(company_benchmark_label_only.benchmark_id)
  end

  it 'includes non-Chemicals benchmarks unchanged' do
    expect(benchmark_ids).to include(steel_benchmark.benchmark_id)
  end

  context 'when Chemicals benchmark uses allowlist value in benchmark_label only' do
    let!(:agricultural_via_label) do
      create(:cp_benchmark,
             sector: chemicals_sector,
             category: 'Company',
             scenario: 'National Pledges',
             subsector: nil,
             benchmark_label: 'Agricultural chemicals',
             release_date: Date.new(2026, 5, 10))
    end

    it 'includes the row' do
      expect(benchmark_ids).to include(agricultural_via_label.benchmark_id)
    end
  end
end
