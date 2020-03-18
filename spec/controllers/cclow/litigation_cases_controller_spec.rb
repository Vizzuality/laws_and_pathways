require 'rails_helper'

RSpec.describe CCLOW::LitigationCasesController, type: :controller do
  let!(:litigation1) {
    create(
      :litigation,
      :published,
      title: 'Super Litigation',
      keywords: [
        build(:keyword, name: 'keyword1'),
        build(:keyword, name: 'keyword2')
      ],
      responses: [
        build(:response, name: 'response1'),
        build(:response, name: 'response2')
      ],
      legislations: [
        build(:legislation, title: 'Legislation 1'),
        build(:legislation, title: 'Legislation 2')
      ]
    )
  }
  let!(:litigation2) { create(:litigation, :published, title: 'Example', summary: 'Litigation example') }
  let!(:litigation3) { create(:litigation, :published, title: 'Litigation Example', summary: 'Example') }
  let!(:litigation4) { create(:litigation, :draft, title: 'This one is unpublished', summary: 'Example') }

  before do
    create(:litigation_event, eventable: litigation1,  date: Date.parse('2018-04-03'))
    create(:litigation_event, eventable: litigation1,  date: Date.parse('2018-03-02'))

    create(:litigation_event, eventable: litigation2,  date: Date.parse('2019-03-02'))
    create(:litigation_event, eventable: litigation2,  date: Date.parse('2019-05-01'))

    create(:litigation_event, eventable: litigation3,  date: Date.parse('2018-03-03'))
    create(:litigation_event, eventable: litigation3,  date: Date.parse('2018-05-01'))
  end

  describe 'GET index' do
    context 'without filters' do
      subject { get :index }

      it { is_expected.to be_successful }

      it('should return all published litigations') do
        subject
        expect(assigns(:litigations).size).to eq(3)
      end

      it('should be ordered by latest date of the event') do
        subject
        expect(assigns(:litigations)).to eq([litigation2, litigation3, litigation1])
      end

      it 'responds to csv' do
        get :index, format: :csv
        expect(response.content_type).to eq('text/csv')
        expect(response.body).to match_snapshot('cclow_litigation_cases_controller_csv')
      end
    end

    context 'with query param without matches' do
      let(:params) { {q: 'Query'} }

      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it('should return no litigations') do
        subject
        expect(assigns(:litigations).size).to eq(0)
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end

    context 'with query param with matches' do
      let(:params) { {q: 'litigation example'} }
      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it 'should return litigations' do
        subject
        expect(assigns(:litigations).size).to eq(2)
      end

      it('should be ordered by relevance') do
        subject
        expect(assigns(:litigations)).to eq([litigation3, litigation2])
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end
  end
end
