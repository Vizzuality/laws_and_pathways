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

      it 'should return data and meta attributes' do
        expect(subject.keys).to contain_exactly(:data, :meta)
      end

      it 'should return all alignment years' do
        expect(subject[:data].keys).to contain_exactly('2025', '2035', '2050')
      end

      it 'should return all sectors inside meta' do
        expect(subject[:meta][:sectors]).to contain_exactly(@bank_sector1.name, @bank_sector2.name)
      end

      it 'should return all portfolio categories inside meta' do
        expect(subject[:meta][:portfolios]).to eq(CP::Portfolio::NAMES_WITH_CATEGORIES)
      end

      it 'should return all band sectors for each alignment year' do
        expect(subject[:data]['2025'].keys).to contain_exactly(@bank_sector1.name, @bank_sector2.name)
        expect(subject[:data]['2035'].keys).to contain_exactly(@bank_sector1.name, @bank_sector2.name)
        expect(subject[:data]['2050'].keys).to contain_exactly(@bank_sector1.name, @bank_sector2.name)
      end

      it 'should return all portfolio for each sector' do
        expect(subject[:data]['2025'][@bank_sector1.name][:portfolio_values].keys).to contain_exactly(*CP::Portfolio::NAMES)
        expect(subject[:data]['2025'][@bank_sector2.name][:portfolio_values].keys).to contain_exactly(*CP::Portfolio::NAMES)
      end

      it 'should return assumptions for each sector' do
        expect(subject[:data]['2025'][@bank_sector1.name][:assumptions]).to eq(@cp_assessment1.assumptions)
        expect(subject[:data]['2025'][@bank_sector2.name][:assumptions]).to eq(@cp_assessment2.assumptions)
      end

      it 'should return alignment values for selected portfolio' do
        expect(subject[:data]['2025'][@bank_sector1.name][:portfolio_values]['Mortgages']).to eq(@cp_matrix1.cp_alignment_2025)
        expect(subject[:data]['2025'][@bank_sector1.name][:portfolio_values]['Auto Loans']).to eq(@cp_matrix2.cp_alignment_2025)
        expect(subject[:data]['2025'][@bank_sector1.name][:portfolio_values]['Corporate lending']).to eq(nil)
        expect(subject[:data]['2025'][@bank_sector2.name][:portfolio_values]['Mortgages']).to eq(nil)
        expect(subject[:data]['2025'][@bank_sector2.name][:portfolio_values]['Auto Loans']).to eq(nil)
        expect(subject[:data]['2025'][@bank_sector2.name][:portfolio_values]['Corporate lending'])
          .to eq(@cp_matrix3.cp_alignment_2025)

        expect(subject[:data]['2035'][@bank_sector1.name][:portfolio_values]['Mortgages']).to eq(@cp_matrix1.cp_alignment_2035)
        expect(subject[:data]['2035'][@bank_sector1.name][:portfolio_values]['Auto Loans']).to eq(@cp_matrix2.cp_alignment_2035)
        expect(subject[:data]['2035'][@bank_sector2.name][:portfolio_values]['Corporate lending'])
          .to eq(@cp_matrix3.cp_alignment_2035)

        expect(subject[:data]['2050'][@bank_sector1.name][:portfolio_values]['Mortgages']).to eq(@cp_matrix1.cp_alignment_2050)
        expect(subject[:data]['2050'][@bank_sector1.name][:portfolio_values]['Auto Loans']).to eq(@cp_matrix2.cp_alignment_2050)
        expect(subject[:data]['2050'][@bank_sector2.name][:portfolio_values]['Corporate lending'])
          .to eq(@cp_matrix3.cp_alignment_2050)
      end
    end

    context 'when cp_assessmentable is not provided' do
      subject { described_class.new(nil).matrix_data }

      it 'should return empty array' do
        expect(subject[:data]).to eq([])
      end
    end
  end
end
