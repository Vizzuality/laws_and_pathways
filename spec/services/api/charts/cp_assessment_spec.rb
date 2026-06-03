require 'rails_helper'

RSpec.describe Api::Charts::CPAssessment do
  before_all do
    @sector_a = create(:tpi_sector, name: 'Sector A', categories: %w[Bank Company])
    @sector_b = create(:tpi_sector, name: 'Sector B', categories: %w[Bank Company])
    @company_sector_a_1 = create(:company, :published, sector: @sector_a)
    @company_sector_a_2 = create(:company, :published, sector: @sector_a)
    @company_sector_a_3 = create(:company, :published, sector: @sector_a)
    @bank_sector_a_1 = create(:bank)
    @bank_sector_a_2 = create(:bank)
    @bank_sector_a_3 = create(:bank)

    @company_sector_b_1 = create(:company, :published, sector: @sector_b)
    @bank_sector_b_1 = create(:bank)

    # Sector B - should be ignored
    create(:cp_assessment,
           sector: @sector_b,
           cp_assessmentable: @company_sector_b_1,
           emissions: {'2015' => 400.0, '2016' => 500.0})
    create(:cp_assessment,
           sector: @sector_b,
           cp_assessmentable: @bank_sector_b_1,
           emissions: {'2015' => 400.0, '2016' => 500.0})
    # Sector A Company Benchmarks
    create(:cp_benchmark,
           scenario: 'scenario',
           release_date: 12.months.ago,
           sector: @sector_a,
           category: 'Company',
           emissions: {'2016' => 130.0, '2017' => 120.0, '2018' => 100.0})
    create(:cp_benchmark,
           scenario: 'scenario',
           release_date: 7.months.ago,
           sector: @sector_a,
           category: 'Company',
           emissions: {'2016' => 115.5, '2017' => 122.0, '2018' => 124.0})
    create(:cp_benchmark,
           scenario: 'scenario regional',
           release_date: 12.months.ago,
           region: 'Europe',
           sector: @sector_a,
           category: 'Company',
           emissions: {'2016' => 100.0, '2017' => 120.0, '2018' => 124.0})
    # Sector A Bank Benchmarks
    create(:cp_benchmark,
           scenario: 'scenario',
           release_date: 12.months.ago,
           sector: @sector_a,
           category: 'Bank',
           region: 'Europe',
           emissions: {'2016' => 130.0, '2017' => 120.0, '2018' => 100.0})
    create(:cp_benchmark,
           scenario: 'scenario',
           release_date: 7.months.ago,
           sector: @sector_a,
           category: 'Bank',
           region: 'Europe',
           emissions: {'2016' => 115.5, '2017' => 122.0, '2018' => 124.0})
    create(:cp_benchmark,
           scenario: 'scenario',
           release_date: 12.months.ago,
           region: 'Europe',
           sector: @sector_a,
           category: 'Bank',
           emissions: {'2016' => 100.0, '2017' => 120.0, '2018' => 124.0})

    # create some company assessment for sector A
    create(:cp_assessment,
           assessment_date: 10.months.ago,
           publication_date: 10.months.ago,
           last_reported_year: 2018,
           sector: @sector_a,
           cp_assessmentable: @company_sector_a_1,
           emissions: {'2017' => 90.0, '2018' => 90.0, '2019' => 110.0})
    create(:cp_assessment,
           assessment_date: 6.months.ago,
           publication_date: 6.months.ago,
           last_reported_year: 2018,
           sector: @sector_a,
           cp_assessmentable: @company_sector_a_1,
           emissions: {'2017' => 100.0, '2018' => 70.0, '2019' => 110.0})
    create(:cp_assessment,
           assessment_date: 11.months.ago,
           publication_date: 11.months.ago,
           last_reported_year: 2018,
           sector: @sector_a,
           cp_assessmentable: @company_sector_a_2,
           region: 'Europe',
           emissions: {'2017' => 40.0, '2018' => 50.0})
    create(:cp_assessment,
           assessment_date: 11.months.ago,
           publication_date: 11.months.ago,
           last_reported_year: 2018,
           region: 'Europe',
           sector: @sector_a,
           cp_assessmentable: @company_sector_a_3,
           emissions: {'2017' => 30.0, '2018' => 20.0})
    # create some bank assessment for sector A
    create(:cp_assessment,
           assessment_date: 10.months.ago,
           publication_date: 10.months.ago,
           last_reported_year: 2018,
           sector: @sector_a,
           region: 'Europe',
           cp_assessmentable: @bank_sector_a_1,
           emissions: {'2017' => 90.0, '2018' => 90.0, '2019' => 110.0})
    create(:cp_assessment,
           assessment_date: 6.months.ago,
           publication_date: 6.months.ago,
           last_reported_year: 2018,
           sector: @sector_a,
           region: 'Europe',
           cp_assessmentable: @bank_sector_a_1,
           emissions: {'2017' => 110.0, '2018' => 80.0, '2019' => 110.0})
    create(:cp_assessment,
           assessment_date: 11.months.ago,
           publication_date: 11.months.ago,
           last_reported_year: 2018,
           sector: @sector_a,
           cp_assessmentable: @bank_sector_a_2,
           region: 'Europe',
           emissions: {'2017' => 40.0, '2018' => 50.0})
    create(:cp_assessment,
           assessment_date: 11.months.ago,
           publication_date: 11.months.ago,
           last_reported_year: 2018,
           region: 'Europe',
           sector: @sector_a,
           cp_assessmentable: @bank_sector_a_3,
           emissions: {'2017' => 30.0, '2018' => 20.0})
    # should be ignored as not published yet
    create(:cp_assessment,
           assessment_date: 11.months.ago,
           publication_date: 6.months.from_now,
           last_reported_year: 2018,
           sector: @sector_a,
           cp_assessmentable: @company_sector_a_1,
           emissions: {'2017' => 80.0, '2018' => 80.0, '2019' => 110.0})
  end

  describe '.emissions_data' do
    context 'when assessment belongs to company' do
      context 'when CP assessment is not nil' do
        context 'for last assessment' do
          subject { described_class.new(@company_sector_a_1.latest_cp_assessment, 'global') }

          it 'returns emissions data from: company, sector avg & sector benchmarks' do
            company_sector_a_1_data = subject.emissions_data.find { |s| s[:name] == @company_sector_a_1.name }[:data]
            sector_average_data = subject.emissions_data.find { |s| s[:name] == "#{@sector_a.name} sector mean" }[:data]
            cp_benchmarks_data = subject.emissions_data.find { |s| s[:name] == 'scenario' }[:data]

            avg_2017 = ((100.0 + 40.0 + 30.0) / 3).round(2)
            avg_2018 = ((70.0 + 50.0 + 20.0) / 3).round(2)

            expect(company_sector_a_1_data).to eq(2017 => 100.0, 2018 => 70.0, 2019 => 110.0)
            # sector average_data is only up to last_reported_year
            expect(sector_average_data).to eq(2017 => avg_2017, 2018 => avg_2018)
            expect(cp_benchmarks_data).to eq(2016 => 115.5, 2017 => 122.0, 2018 => 124.0)
          end
        end

        context 'for regional view' do
          subject { described_class.new(@company_sector_a_2.latest_cp_assessment, 'regional') }

          it 'return emissions data from: company, regional sector avg & regional sector benchmarks' do
            # company a_2 and a_3 have regional assessments count only those to average

            company_sector_a_2_data = subject.emissions_data.find { |s| s[:name] == @company_sector_a_2.name }[:data]
            sector_average_data = subject.emissions_data.find { |s| s[:name] == "Europe #{@sector_a.name} sector mean" }[:data]
            cp_benchmarks_data = subject.emissions_data.find { |s| s[:name] == 'scenario regional' }[:data]

            avg_2017 = ((40.0 + 30.0) / 2).round(2)
            avg_2018 = ((50.0 + 20.0) / 2).round(2)

            expect(company_sector_a_2_data).to eq(2017 => 40.0, 2018 => 50.0)
            # sector average_data is only up to last_reported_year
            expect(sector_average_data).to eq(2017 => avg_2017, 2018 => avg_2018)
            expect(cp_benchmarks_data).to eq(2016 => 100.0, 2017 => 120.0, 2018 => 124.0)
          end
        end

        context 'for first historic assessment' do
          subject do
            described_class.new(
              @company_sector_a_1.cp_assessments.currently_published.order(:assessment_date).first,
              'global'
            )
          end

          it 'returns emissions data from: company, sector avg & sector benchmarks' do
            company_sector_a_1_data = subject.emissions_data.find { |s| s[:name] == @company_sector_a_1.name }[:data]
            sector_average_data = subject.emissions_data.find { |s| s[:name] == "#{@sector_a.name} sector mean" }[:data]
            cp_benchmarks_data = subject.emissions_data.find { |s| s[:name] == 'scenario' }[:data]

            avg_2017 = ((90.0 + 40.0 + 30.0) / 3).round(2)
            avg_2018 = ((90.0 + 50.0 + 20.0) / 3).round(2)

            expect(company_sector_a_1_data).to eq(2017 => 90.0, 2018 => 90.0, 2019 => 110.0)
            # sector average_data is only up to last_reported_year
            expect(sector_average_data).to eq(2017 => avg_2017, 2018 => avg_2018)
            expect(cp_benchmarks_data).to eq(2016 => 130.0, 2017 => 120.0, 2018 => 100.0)
          end
        end
      end

      context 'when CP assessment is nil' do
        subject { described_class.new(nil, nil) }

        it 'returns no emissions data' do
          expect(subject.emissions_data).to eq []
        end
      end
    end

    context 'when assessment belongs to bank' do
      context 'for last assessment' do
        subject { described_class.new(@bank_sector_a_1.latest_cp_assessment, 'regional') }

        it 'returns emissions data from: bank, sector avg & sector benchmarks' do
          bank_sector_a_1_data = subject.emissions_data.find { |s| s[:name] == @bank_sector_a_1.name }[:data]
          sector_average_data = subject.emissions_data.find { |s| s[:name] == 'Sector mean' }[:data]
          cp_benchmarks_data = subject.emissions_data.find { |s| s[:name] == 'scenario' }[:data]

          avg_2017 = ((100.0 + 40.0 + 30.0) / 3).round(2)
          avg_2018 = ((70.0 + 50.0 + 20.0) / 3).round(2)

          expect(bank_sector_a_1_data).to eq(2017 => 110.0, 2018 => 80.0, 2019 => 110.0)
          # sector average_data is only up to last_reported_year
          expect(sector_average_data).to eq(2017 => avg_2017, 2018 => avg_2018)
          expect(cp_benchmarks_data).to eq(2016 => 115.5, 2017 => 122.0, 2018 => 124.0)
        end
      end

      context 'for first historic assessment' do
        subject do
          described_class.new(
            @bank_sector_a_1.cp_assessments.currently_published.order(:assessment_date).first,
            'regional'
          )
        end

        it 'returns emissions data from: company, sector avg & sector benchmarks' do
          bank_sector_a_1_data = subject.emissions_data.find { |s| s[:name] == @bank_sector_a_1.name }[:data]
          sector_average_data = subject.emissions_data.find { |s| s[:name] == 'Sector mean' }[:data]
          cp_benchmarks_data = subject.emissions_data.find { |s| s[:name] == 'scenario' }[:data]

          avg_2017 = ((90.0 + 40.0 + 30.0) / 3).round(2)
          avg_2018 = ((90.0 + 50.0 + 20.0) / 3).round(2)

          expect(bank_sector_a_1_data).to eq(2017 => 90.0, 2018 => 90.0, 2019 => 110.0)
          # sector average_data is only up to last_reported_year
          expect(sector_average_data).to eq(2017 => avg_2017, 2018 => avg_2018)
          expect(cp_benchmarks_data).to eq(2016 => 130.0, 2017 => 120.0, 2018 => 100.0)
        end
      end
    end
  end

  describe 'Chemicals sector' do
    let(:chemicals_sector) { create(:tpi_sector, name: 'Chemicals', categories: %w[Company]) }
    let(:company) { create(:company, :published, sector: chemicals_sector, name: 'BASF SE') }
    let(:company_subsector) { create(:company_subsector, company: company, subsector: 'BASF') }
    let!(:assessment) do
      create(:cp_assessment,
             sector: chemicals_sector,
             cp_assessmentable: company,
             company_subsector: company_subsector,
             publication_date: 3.months.ago,
             assessment_date: 3.months.ago,
             last_reported_year: 2018,
             emissions: {'2017' => 100.0, '2018' => 90.0})
    end

    before do
      create(:cp_benchmark,
             sector: chemicals_sector,
             category: 'Company',
             scenario: '1.5 Degrees',
             subsector: 'BASF',
             release_date: 6.months.ago,
             emissions: {'2017' => 80.0, '2018' => 70.0})
      create(:cp_benchmark,
             sector: chemicals_sector,
             category: 'Company',
             scenario: 'Below 2 Degrees',
             subsector: 'BASF',
             release_date: 6.months.ago,
             emissions: {'2017' => 85.0, '2018' => 75.0})
      create(:cp_benchmark,
             sector: chemicals_sector,
             category: 'Company',
             scenario: 'National Pledges',
             subsector: 'BASF',
             release_date: 6.months.ago,
             emissions: {'2017' => 90.0, '2018' => 80.0})
      create(:cp_benchmark,
             sector: chemicals_sector,
             category: 'Company',
             scenario: '1.5 Degrees',
             subsector: 'Other Co',
             release_date: 6.months.ago,
             emissions: {'2017' => 50.0, '2018' => 40.0})
    end

    subject { described_class.new(assessment, 'global') }

    it 'uses generic company series name and excludes sector mean' do
      expect(subject.emissions_data.find { |s| s[:name] == 'Company' }).to be_present
      expect(subject.emissions_data.find { |s| s[:name] == company.name }).to be_nil
      expect(subject.emissions_data.any? { |s| s[:name]&.include?('sector mean') }).to be false
    end

    it 'returns only benchmarks matching the company match key' do
      scenario_names = subject.emissions_data.select { |s| s[:type] == 'area' }.map { |s| s[:name] }
      expect(scenario_names).to contain_exactly('1.5 Degrees', 'Below 2 Degrees', 'National Pledges')
    end

    context 'when match key is missing' do
      let(:company_subsector) { nil }

      before do
        assessment.update!(company_subsector_id: nil)
      end

      it 'returns no benchmark areas' do
        expect(subject.emissions_data.select { |s| s[:type] == 'area' }).to be_empty
      end
    end
  end
end
