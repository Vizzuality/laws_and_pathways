require 'rails_helper'

RSpec.describe TPI::SectorsController, type: :controller do
  let_it_be(:geography) { create(:geography, name: 'Poland', iso: 'PL') }
  let_it_be(:sector1) { create(:tpi_sector, name: 'Technology') }
  let_it_be(:sector2) { create(:tpi_sector, name: 'Energy') }
  let_it_be(:benchmark1) { create(:cp_benchmark, sector: sector1, release_date: '2011-05-01', scenario: 'Below 2 Degrees') }
  let_it_be(:benchmark2) { create(:cp_benchmark, sector: sector1, release_date: '2011-05-01', scenario: 'Paris Pledges') }
  let_it_be(:benchmark3) { create(:cp_benchmark, sector: sector2, release_date: '2013-05-01', scenario: 'Paris Pledges') }

  let_it_be(:company1) {
    create(
      :company,
      :published,
      geography: geography,
      cp_assessments: [
        build(:cp_assessment, assessment_date: '2012-05-01', publication_date: '2012-05-01', cp_alignment: 'Below 2 Degrees'),
        build(:cp_assessment, assessment_date: '2019-05-01', publication_date: '2019-05-01', cp_alignment: 'Paris Pledges')
      ],
      mq_assessments: [
        build(:mq_assessment, assessment_date: '2013-05-01', publication_date: '2013-05-01'),
        build(:mq_assessment, assessment_date: '2014-05-01', publication_date: '2014-05-01')
      ],
      sector: sector1,
      market_cap_group: 'large',
      name: 'Hitachi',
      isin: 'hitachi-isin',
      sedol: 'hitachi-sedol'
    )
  }
  let_it_be(:company2) {
    create(
      :company,
      :published,
      geography: geography,
      cp_assessments: [
        build(:cp_assessment, assessment_date: '2014-05-01', publication_date: '2014-05-01', cp_alignment: 'Below 2 Degrees'),
        build(:cp_assessment, assessment_date: '2020-05-01', publication_date: '2020-05-01', cp_alignment: 'Paris Pledges')
      ],
      mq_assessments: [
        build(:mq_assessment, assessment_date: '2014-05-01', publication_date: '2014-05-01'),
        build(:mq_assessment, assessment_date: '2020-05-01', publication_date: '2020-05-01')
      ],
      sector: sector1,
      name: 'Microsoft',
      market_cap_group: 'large',
      isin: 'microsoft-isin',
      sedol: 'microsoft-sedol'
    )
  }
  let_it_be(:company3) {
    create(
      :company,
      :published,
      geography: geography,
      cp_assessments: [
        build(:cp_assessment, assessment_date: '2014-05-01', publication_date: '2014-05-01'),
        build(:cp_assessment, assessment_date: '2020-06-01', publication_date: '2020-06-01')
      ],
      mq_assessments: [
        build(:mq_assessment, assessment_date: '2015-05-01', publication_date: '2015-05-01'),
        build(:mq_assessment, assessment_date: '2021-05-01', publication_date: '2021-05-01')
      ],
      sector: sector2,
      name: 'Energy company',
      market_cap_group: 'small',
      isin: 'energy-company-isin',
      sedol: 'energy-company-sedol'
    )
  }
  let_it_be(:company4) {
    create(
      :company,
      :pending,
      geography: geography,
      sector: sector2,
      name: 'Energy 2 company',
      market_cap_group: 'small',
      isin: 'energy-2-company-isin',
      sedol: 'energy-2-company-sedol'
    )
  }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: sector1.slug} }

    it { is_expected.to be_successful }
  end

  describe 'GET user download' do
    subject { get :user_download, params: {id: sector1.slug} }

    it { is_expected.to be_successful }

    it 'returns zip file' do
      subject
      expect(response.content_type).to eq('application/zip')
    end

    describe 'zip file' do
      it 'has proper content' do
        subject

        timestamp = Time.now.strftime('%d%m%Y')
        entries_names = []
        entries_csv_json = {}

        zip_io = StringIO.new(response.body)
        Zip::File.open_buffer(zip_io) do |zipfile|
          zipfile.each do |entry|
            entries_names << entry.name
            entries_csv_json[entry.name] = parse_csv_to_json(entry.get_input_stream.read)
          end
        end

        expect(entries_names).to include("Sector_Benchmarks_#{timestamp}.csv")
        expect(entries_names).to include("CP_Assessments_#{timestamp}.csv")
        expect(entries_names).to include('Company_Latest_Assessments.csv')
        expect(entries_names).to include("MQ_Assessments_Methodology_1_#{timestamp}.csv")

        expect(entries_csv_json["Sector_Benchmarks_#{timestamp}.csv"])
          .to match_snapshot('tpi_single_sector_user_download_zip_sector_benchmarks_csv')
        expect(entries_csv_json["CP_Assessments_#{timestamp}.csv"])
          .to match_snapshot('tpi_single_sector_user_download_cp_assessments_csv')
        expect(entries_csv_json['Company_Latest_Assessments.csv'])
          .to match_snapshot('tpi_single_sector_user_company_latest_assessments_csv')
        expect(entries_csv_json['Company_Latest_Assessments.csv'])
          .to match_snapshot('tpi_single_sector_user_company_latest_assessments_csv')
        expect(entries_csv_json["MQ_Assessments_Methodology_1_#{timestamp}.csv"])
          .to match_snapshot('tpi_single_sector_user_mq_assessments_methodology_1_csv')
      end
    end
  end

  describe 'GET user download all' do
    subject { get :user_download_all }

    it { is_expected.to be_successful }

    it 'returns zip file' do
      subject
      expect(response.content_type).to eq('application/zip')
    end

    describe 'zip file' do
      it 'has proper content' do
        subject

        timestamp = Time.now.strftime('%d%m%Y')
        entries_names = []
        entries_csv_json = {}

        zip_io = StringIO.new(response.body)
        Zip::File.open_buffer(zip_io) do |zipfile|
          zipfile.each do |entry|
            entries_names << entry.name
            entries_csv_json[entry.name] = parse_csv_to_json(entry.get_input_stream.read)
          end
        end

        expect(entries_names).to include("Sector_Benchmarks_#{timestamp}.csv")
        expect(entries_names).to include("CP_Assessments_#{timestamp}.csv")
        expect(entries_names).to include('Company_Latest_Assessments.csv')
        expect(entries_names).to include("MQ_Assessments_Methodology_1_#{timestamp}.csv")

        expect(entries_csv_json["Sector_Benchmarks_#{timestamp}.csv"])
          .to match_snapshot('tpi_all_sectors_user_download_zip_sector_benchmarks_csv')
        expect(entries_csv_json["CP_Assessments_#{timestamp}.csv"])
          .to match_snapshot('tpi_all_sectors_user_download_cp_assessments_csv')
        expect(entries_csv_json['Company_Latest_Assessments.csv'])
          .to match_snapshot('tpi_all_sectors_user_company_latest_assessments_csv')
        expect(entries_csv_json['Company_Latest_Assessments.csv'])
          .to match_snapshot('tpi_all_sectors_user_company_latest_assessments_csv')
        expect(entries_csv_json["MQ_Assessments_Methodology_1_#{timestamp}.csv"])
          .to match_snapshot('tpi_all_sectors_user_mq_assessments_methodology_1_csv')
      end
    end
  end
end