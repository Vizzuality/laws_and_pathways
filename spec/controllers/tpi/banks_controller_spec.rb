require 'rails_helper'

RSpec.describe TPI::BanksController, type: :controller do
  let_it_be(:geography) { create(:geography, name: 'Poland', iso: 'PL') }
  let_it_be(:bank1) {
    create(
      :bank,
      name: 'Bank 1',
      geography: geography,
      isin: '2342343243, 435434445',
      sedol: '3234343',
      market_cap_group: 'small',
      latest_information: 'Bank1 Latest info'
    )
  }
  let_it_be(:bank2) {
    create(
      :bank,
      name: 'Bank 2',
      geography: geography,
      isin: '3342332, 4444444',
      sedol: '3434211',
      market_cap_group: 'large',
      latest_information: 'Bank2 Latest info'
    )
  }
  let_it_be(:cp_assessment1) do
    create(
      :cp_assessment,
      cp_assessmentable: bank1,
      sector: create(:tpi_sector, name: 'AAA'),
      assessment_date: Date.parse('2022-06-30'),
      publication_date: Date.parse('2022-07-30')
    )
  end
  let_it_be(:cp_assessment2) do
    create(
      :cp_assessment,
      cp_assessmentable: bank2,
      sector: create(:tpi_sector, name: 'BBB'),
      assessment_date: Date.parse('2022-06-30'),
      publication_date: Date.parse('2022-07-30')
    )
  end
  let_it_be(:cp_matrix1) { create :cp_matrix, cp_assessment: cp_assessment1 }
  let_it_be(:cp_matrix1) { create :cp_matrix, cp_assessment: cp_assessment2 }

  before_all do
    i_area_1 = create(:bank_assessment_indicator, number: '1', indicator_type: 'area', text: 'Commitment')
    i_sub_area_1 = create(:bank_assessment_indicator, number: '1.1', indicator_type: 'sub_area', text: 'Commitment subarea')
    i_indicator_1 = create(:bank_assessment_indicator, number: '1.1.1', indicator_type: 'indicator', text: 'Commitment Indicator')
    i_subindicator_1_1 = create(:bank_assessment_indicator, number: '1.1.1.a', indicator_type: 'sub_indicator', text: 'Maybe a')
    i_subindicator_1_2 = create(:bank_assessment_indicator, number: '1.1.1.b', indicator_type: 'sub_indicator', text: 'Maybe b')
    i_area_2 = create(:bank_assessment_indicator, number: '2', indicator_type: 'area', text: 'Targets')
    i_indicator_2 = create(:bank_assessment_indicator, number: '2.1', indicator_type: 'indicator', text: 'Target Indicator')
    i_subindicator_2_1 = create(:bank_assessment_indicator, number: '2.1.a', indicator_type: 'sub_indicator', text: 'Maybe a')
    i_subindicator_2_2 = create(:bank_assessment_indicator, number: '2.1.b', indicator_type: 'sub_indicator', text: 'Maybe b')

    ba1 = create(:bank_assessment, bank: bank1, assessment_date: Date.parse('2020-10-23'))
    {
      i_area_1 => 50,
      i_sub_area_1 => nil,
      i_indicator_1 => 50,
      i_subindicator_1_1 => 'Yes',
      i_subindicator_1_2 => 'No',
      i_area_2 => 100,
      i_indicator_2 => 100,
      i_subindicator_2_1 => 'Yes',
      i_subindicator_2_2 => 'Yes'
    }.each do |indicator, value|
      create(:bank_assessment_result, assessment: ba1, indicator: indicator, value: value)
    end

    ba2 = create(:bank_assessment, bank: bank2, assessment_date: Date.parse('2020-10-23'))
    {
      i_area_1 => 50,
      i_sub_area_1 => nil,
      i_indicator_1 => 50,
      i_subindicator_1_1 => 'No',
      i_subindicator_1_2 => 'Yes',
      i_area_2 => 0,
      i_indicator_2 => 0,
      i_subindicator_2_1 => 'No',
      i_subindicator_2_2 => 'No'
    }.each do |indicator, value|
      create(:bank_assessment_result, assessment: ba2, indicator: indicator, value: value)
    end
  end

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: bank1.slug} }

    it { is_expected.to be_successful }
  end

  describe 'GET user download' do
    subject { get :user_download }

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
            entries_csv_json[entry.name] = parse_csv_to_json(entry.get_input_stream.read) if entry.name.ends_with?('.csv')
          end
        end

        expect(entries_names).to include('Framework of pilot indicators.csv')
        expect(entries_names).to include("Bank assessments #{timestamp}.csv")
        expect(entries_names).to include("Bank CP assessments #{timestamp}.csv")

        expect(entries_csv_json['Framework of pilot indicators.csv'])
          .to match_snapshot('tpi_banking_tool_user_download_zip_indicators_csv')
        expect(entries_csv_json["Bank assessments #{timestamp}.csv"])
          .to match_snapshot('tpi_banking_tool_user_download_zip_bank_assessments_csv')
        expect(entries_csv_json["Bank CP assessments #{timestamp}.csv"])
          .to match_snapshot('tpi_banking_tool_user_download_zip_bank_cp_assessments_csv')
      end
    end
  end
end
