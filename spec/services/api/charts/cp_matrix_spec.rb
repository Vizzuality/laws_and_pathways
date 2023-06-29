require 'rails_helper'

RSpec.describe Api::Charts::CPMatrix do
  before_all do
    @bank_sector1 = create :tpi_sector, categories: [Bank]
    @bank_sector2 = create :tpi_sector, categories: [Bank]
    @company_sector1 = create :tpi_sector, categories: [Company]

    @bank = create :bank

    @cp_assessment1 = create :cp_assessment, cp_assessmentable: @bank, sector: @bank_sector1
    @cp_assessment2 = create :cp_assessment, cp_assessmentable: @bank, sector: @bank_sector2

    @cp_matrix1 = create :cp_matrix, cp_assessment: @cp_assessment1, portfolio: 'Mortgages'
    @cp_matrix2 = create :cp_matrix, cp_assessment: @cp_assessment1, portfolio: 'Auto Loans'
    @cp_matrix3 = create :cp_matrix, cp_assessment: @cp_assessment2, portfolio: 'Corporate lending'
  end

  describe '#matrix_data' do
    context 'when cp_assessmentable is provided' do
      subject { described_class.new(@bank).matrix_data }

      it 'should return all alignment years' do
        expect(subject.keys).to contain_exactly('2025', '2035', '2050')
      end

      it 'should return all band sectors for each alignment year' do
        expect(subject['2025'].keys).to contain_exactly(@bank_sector1.name, @bank_sector2.name)
        expect(subject['2035'].keys).to contain_exactly(@bank_sector1.name, @bank_sector2.name)
        expect(subject['2050'].keys).to contain_exactly(@bank_sector1.name, @bank_sector2.name)
      end

      it 'should return all portfolio for each sector' do
        expect(subject['2025'][@bank_sector1.name].keys).to contain_exactly(*CP::Portfolio::NAMES)
        expect(subject['2025'][@bank_sector2.name].keys).to contain_exactly(*CP::Portfolio::NAMES)
      end

      it 'should return alignment values for selected portfolio' do
        expect(subject['2025'][@bank_sector1.name]['Mortgages']).to eq(@cp_matrix1.cp_alignment_2025)
        expect(subject['2025'][@bank_sector1.name]['Auto Loans']).to eq(@cp_matrix2.cp_alignment_2025)
        expect(subject['2025'][@bank_sector1.name]['Corporate lending']).to eq(nil)
        expect(subject['2025'][@bank_sector2.name]['Mortgages']).to eq(nil)
        expect(subject['2025'][@bank_sector2.name]['Auto Loans']).to eq(nil)
        expect(subject['2025'][@bank_sector2.name]['Corporate lending']).to eq(@cp_matrix3.cp_alignment_2025)

        expect(subject['2035'][@bank_sector1.name]['Mortgages']).to eq(@cp_matrix1.cp_alignment_2035)
        expect(subject['2035'][@bank_sector1.name]['Auto Loans']).to eq(@cp_matrix2.cp_alignment_2035)
        expect(subject['2035'][@bank_sector2.name]['Corporate lending']).to eq(@cp_matrix3.cp_alignment_2035)

        expect(subject['2050'][@bank_sector1.name]['Mortgages']).to eq(@cp_matrix1.cp_alignment_2050)
        expect(subject['2050'][@bank_sector1.name]['Auto Loans']).to eq(@cp_matrix2.cp_alignment_2050)
        expect(subject['2050'][@bank_sector2.name]['Corporate lending']).to eq(@cp_matrix3.cp_alignment_2050)
      end
    end

    context 'when cp_assessmentable is not provided' do
      subject { described_class.new(nil).matrix_data }

      it 'should return empty array' do
        expect(subject).to eq([])
      end
    end
  end
end
