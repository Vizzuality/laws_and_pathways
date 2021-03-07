require 'rails_helper'

RSpec.describe CCLOW::LegislationAndPoliciesController, type: :controller do
  let_it_be(:user) { create(:admin_user) }
  let_it_be(:geography) { create(:geography, created_by: user, name: 'Poland', iso: 'POL') }
  let_it_be(:sector1) { create(:laws_sector, name: 'sector1') }
  let_it_be(:sector2) { create(:laws_sector, name: 'sector2') }
  let_it_be(:keyword) { create(:keyword, name: 'climate') }
  let_it_be(:parent_legislation) { create(:legislation, created_by: user, title: 'Parent Legislation') }
  let_it_be(:instrument_type) { create(:instrument_type, name: 'instrument_type_test') }
  let_it_be(:legislation1) {
    create(
      :legislation,
      :published,
      created_by: user,
      geography: geography,
      title: 'Super Legislation',
      parent: parent_legislation,
      laws_sectors: [sector1, sector2],
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
      ],
      events: [
        build(:legislation_event, date: Date.parse('2018-04-03')),
        build(:legislation_event, date: Date.parse('2018-03-02'))
      ]
    )
  }
  let_it_be(:legislation2) {
    create(
      :legislation,
      :published,
      laws_sectors: [sector1],
      geography: geography,
      title: 'Example',
      description: 'Legislation example',
      keywords: [keyword],
      events: [
        build(:legislation_event, date: Date.parse('2019-03-02')),
        build(:legislation_event, date: Date.parse('2017-05-01'))
      ]
    )
  }
  let_it_be(:legislation3) {
    create(
      :legislation,
      :published,
      created_by: user,
      geography: geography,
      laws_sectors: [sector1],
      title: 'Legislation Example',
      description: 'Example',
      events: [
        build(:legislation_event, date: Date.parse('2018-03-03')),
        build(:legislation_event, date: Date.parse('2018-05-01'))
      ]
    )
  }
  let_it_be(:legislation4) {
    create(
      :legislation,
      :draft,
      created_by: user,
      geography: geography,
      laws_sectors: [sector1],
      title: 'This one is unpublished',
      description: 'Example'
    )
  }

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
        # stub active storage dynamic blob path to test with snapshots
        allow_any_instance_of(Document).to receive(:file_url).and_return('http://internal-url.com')

        get :index, format: :csv
        expect(response.content_type).to eq('text/csv')
        # remove snapshot to update it (from spec/snapshots)
        # make sure no dynamic, sequenced entity values are used
        csv_json = CSV.parse(response.body, headers: true).map(&:to_h).to_json
        expect(csv_json).to match_snapshot('cclow_legislation_and_policies_controller_csv')
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
