require 'rails_helper'

RSpec.describe TPI::ASCORController, type: :controller do
  let_it_be(:ascor_country) { create :ascor_country }
  let_it_be(:ascor_assessment_indicator) { create :ascor_assessment_indicator }
  let_it_be(:ascor_assessment) { create :ascor_assessment, country: ascor_country }
  let_it_be(:ascor_assessment_result) do
    create :ascor_assessment_result, assessment: ascor_assessment, indicator: ascor_assessment_indicator
  end

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: ascor_country.slug} }

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

        entries_names = []
        entries_csv_json = {}
        zip_io = StringIO.new(response.body)
        Zip::File.open_buffer(zip_io) do |zipfile|
          zipfile.each do |entry|
            entries_names << entry.name
            entries_csv_json[entry.name] = parse_csv_to_json(entry.get_input_stream.read) if entry.name.ends_with?('.csv')
            entries_csv_json[entry.name] = parse_xlsx_to_json(entry.get_input_stream.read) if entry.name.ends_with?('.xlsx')
          end
        end

        expect(entries_names).to include('ASCOR_indicators.xlsx')
        expect(entries_names).to include('ASCOR_assessments_results.xlsx')

        expect(entries_csv_json['ASCOR_indicators.xlsx']).to match_snapshot('tpi_ascor_download_zip_indicators_csv')
        expect(entries_csv_json['ASCOR_assessments_results.xlsx'])
          .to match_snapshot('tpi_ascor_download_zip_assessment_indicators_csv')
      end
    end
  end
end
