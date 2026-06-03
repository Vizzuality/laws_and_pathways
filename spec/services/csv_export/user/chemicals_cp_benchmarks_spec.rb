require 'rails_helper'

RSpec.describe CSVExport::User::ChemicalsCPBenchmarks do
  let(:chemicals_sector) { create(:tpi_sector, name: 'Chemicals', categories: %w[Company]) }
  let!(:primary_benchmark) do
    create(:cp_benchmark,
           sector: chemicals_sector,
           category: 'Company',
           subsector: 'Primary chemicals',
           release_date: Date.new(2026, 5, 10))
  end
  let!(:company_benchmark) do
    create(:cp_benchmark,
           sector: chemicals_sector,
           category: 'Company',
           benchmark_label: 'BASF',
           subsector: 'BASF',
           release_date: Date.new(2026, 5, 10))
  end

  subject { described_class.new(CP::Benchmark.all) }

  def benchmark_ids
    CSV.parse(subject.call, headers: true)['Benchmark ID']
  end

  it 'includes all Chemicals benchmarks including company-specific rows' do
    expect(benchmark_ids).to contain_exactly(primary_benchmark.benchmark_id, company_benchmark.benchmark_id)
  end
end
