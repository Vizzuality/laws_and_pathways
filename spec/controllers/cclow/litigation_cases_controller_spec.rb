require 'rails_helper'

RSpec.describe CCLOW::LitigationCasesController, type: :controller do
  let_it_be(:geography) { create(:geography, name: 'Poland', iso: 'POL') }
  let_it_be(:sector1) { create(:laws_sector, name: 'sector1') }
  let_it_be(:sector2) { create(:laws_sector, name: 'sector2') }
  let_it_be(:litigation1) {
    create(
      :litigation,
      :published,
      geography: geography,
      title: 'Super Litigation',
      laws_sectors: [sector1, sector2],
      keywords: [
        build(:keyword, name: 'keyword1'),
        build(:keyword, name: 'keyword2')
      ],
      responses: [
        build(:response, name: 'response1'),
        build(:response, name: 'response2')
      ],
      legislations: [
        build(:legislation, geography: geography, title: 'Legislation 1'),
        build(:legislation, geography: geography, title: 'Legislation 2')
      ],
      external_legislations: [
        build(:external_legislation, name: 'External legislation1', url: 'https://example.com'),
        build(:external_legislation, name: 'External legislation2', url: 'https://next-example.com')
      ],
      litigation_sides: [
        build(:litigation_side, name: 'Side A1', side_type: 'a', party_type: 'government'),
        build(:litigation_side, name: 'Side A2', side_type: 'a', party_type: 'ngo'),
        build(:litigation_side, name: 'Side B', side_type: 'b', party_type: 'corporation'),
        build(:litigation_side, name: 'Side C', side_type: 'c', party_type: 'government')
      ],
      events: [
        build(:litigation_event, date: Date.parse('2018-04-03')),
        build(:litigation_event, date: Date.parse('2018-03-02'))
      ]
    )
  }
  let_it_be(:litigation2) {
    create(
      :litigation,
      :published,
      laws_sectors: [sector1],
      geography: geography,
      title: 'Example',
      summary: 'Litigation example',
      events: [
        build(:litigation_event, date: Date.parse('2019-03-02')),
        build(:litigation_event, date: Date.parse('2019-05-01'))
      ]
    )
  }
  let_it_be(:litigation3) {
    create(
      :litigation,
      :published,
      laws_sectors: [sector2],
      geography: geography,
      title: 'Litigation Example',
      summary: 'Example',
      events: [
        create(:litigation_event, date: Date.parse('2018-03-03')),
        create(:litigation_event, date: Date.parse('2018-05-01'))
      ]
    )
  }
  let_it_be(:litigation4) {
    create(:litigation, :draft, geography: geography, title: 'This one is unpublished', summary: 'Example')
  }

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
        # remove snapshot to update it (from spec/snapshots)
        # make sure no dynamic, sequenced entity values are used
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
