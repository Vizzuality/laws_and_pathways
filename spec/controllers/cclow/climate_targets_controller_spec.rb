require 'rails_helper'

RSpec.describe CCLOW::ClimateTargetsController, type: :controller, retry: 3 do
  let_it_be(:geography) { create(:geography, name: 'Poland', iso: 'POL') }
  let_it_be(:sector) { create(:laws_sector, name: 'Airlines') }
  let_it_be(:target1) {
    create(
      :target,
      :published,
      geography: geography,
      sector: sector,
      base_year_period: '2020',
      description: 'Super target',
      source: 'framework',
      scopes: [
        build(:scope, name: 'scope1'),
        build(:scope, name: 'scope2')
      ],
      events: [
        build(:target_event, date: Date.parse('2018-04-03')),
        build(:target_event, date: Date.parse('2018-03-02'))
      ]
    )
  }
  let_it_be(:target2) {
    create(
      :target,
      :published,
      sector: sector,
      geography: geography,
      description: 'Example Description',
      events: [
        build(:target_event, date: Date.parse('2019-03-02')),
        build(:target_event, date: Date.parse('2019-05-01'))
      ]
    )
  }
  let_it_be(:target3) {
    create(
      :target,
      :published,
      sector: sector,
      geography: geography,
      description: 'Example',
      events: [
        build(:target_event, date: Date.parse('2018-03-03')),
        build(:target_event, date: Date.parse('2018-05-01'))
      ]
    )
  }
  let_it_be(:target4) {
    create(:target, :draft, sector: sector, geography: geography, description: 'This one is unpublished example')
  }

  describe 'GET index' do
    context 'without filters' do
      subject { get :index }

      it { is_expected.to be_successful }

      it('should return all published targets') do
        subject
        expect(assigns(:climate_targets).size).to eq(3)
      end

      it('should be ordered by latest date of the event') do
        subject
        expect(assigns(:climate_targets)).to eq([target2, target3, target1])
      end

      it 'responds to csv' do
        get :index, format: :csv
        expect(response.content_type).to eq('text/csv')
        # remove snapshot to update it (from spec/snapshots)
        # make sure no dynamic, sequenced entity values are used
        csv_json = CSV.parse(response.body, headers: true).map(&:to_h).to_json
        expect(csv_json).to match_snapshot('cclow_climate_targets_controller_csv')
      end
    end

    context 'with query param without matches' do
      let(:params) { {q: 'Query'} }

      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it('should return no targets') do
        subject
        expect(assigns(:climate_targets).size).to eq(0)
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end

    context 'with query param with matches' do
      let(:params) { {q: 'example'} }
      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it 'should return targets' do
        subject
        expect(assigns(:climate_targets).size).to eq(2)
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end
  end
end
