require 'rails_helper'

RSpec.describe CCLOW::LegislationAndPoliciesController, type: :controller do
  let!(:keyword) { create(:keyword, name: 'climate') }
  let(:parent_legislation) { create(:legislation) }
  let(:instrument_type) { create(:instrument_type, name: 'instrument_type_test') }
  let!(:legislation1) {
    create(
      :legislation,
      :published,
      title: 'Super Legislation',
      parent: parent_legislation,
      laws_sectors: [
        build(:laws_sector, name: 'sector1'),
        build(:laws_sector, name: 'sector2')
      ],
      document_types: [
        build(:document_type, name: 'document_type1'),
        build(:document_type, name: 'document_type2')
      ],
      natural_hazards: [
        build(:natural_hazard, name: 'hazard1'),
        build(:natural_hazard, name: 'hazard2')
      ],
      frameworks: [
        build(:framework, name: 'framework1'),
        build(:framework, name: 'framework2')
      ],
      responses: [
        build(:response, name: 'response1'),
        build(:response, name: 'response2')
      ],
      instruments: [
        build(:instrument, name: 'instrument1', instrument_type: instrument_type),
        build(:instrument, name: 'instrument2', instrument_type: instrument_type)
      ],
      documents: [
        build(:document),
        build(:document_uploaded)
      ]
    )
  }
  let!(:legislation2) {
    create(:legislation, :published, title: 'Example', description: 'Legislation example', keywords: [keyword])
  }
  let!(:legislation3) { create(:legislation, :published, title: 'Legislation Example', description: 'Example') }
  let!(:legislation4) { create(:legislation, :draft, title: 'This one is unpublished', description: 'Example') }

  before do
    create(:legislation_event, eventable: legislation1, date: Date.parse('2018-04-03'))
    create(:legislation_event, eventable: legislation1, date: Date.parse('2018-03-02'))

    create(:legislation_event, eventable: legislation2, date: Date.parse('2019-03-02'))
    create(:legislation_event, eventable: legislation2, date: Date.parse('2017-05-01'))

    create(:legislation_event, eventable: legislation3, date: Date.parse('2018-03-03'))
    create(:legislation_event, eventable: legislation3, date: Date.parse('2018-05-01'))
  end

  describe 'GET index' do
    context 'without filters' do
      subject { get :index }

      it { is_expected.to be_successful }

      it('should return all published legislations') do
        subject
        expect(assigns(:legislations).size).to eq(3)
      end

      it('should be ordered by latest date of the event') do
        subject
        expect(assigns(:legislations)).to eq([legislation2, legislation3, legislation1])
      end

      it 'responds to csv' do
        get :index, format: :csv
        expect(response.content_type).to eq('text/csv')
        # remove snapshot to update it (from spec/snapshots)
        expect(response.body).to match_snapshot('cclow_legislation_and_policies_controller_csv')
      end
    end

    context 'with query param without matches' do
      let(:params) { {q: 'Query'} }

      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it('should return no legislations') do
        subject
        expect(assigns(:legislations).size).to eq(0)
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end

    context 'with query param with matches' do
      let(:params) { {q: 'legislation example'} }
      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it 'should return legislations' do
        subject
        expect(assigns(:legislations).size).to eq(2)
      end

      it('should be ordered by relevance') do
        subject
        expect(assigns(:legislations)).to eq([legislation3, legislation2])
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end

    context 'with query params and keywords' do
      let(:params) { {q: 'legislation example', keywords: [keyword.id]} }
      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it 'should return legislations' do
        subject
        expect(assigns(:legislations).size).to eq(1)
      end
    end
  end
end
