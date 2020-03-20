require 'rails_helper'

RSpec.describe CCLOW::ClimateTargetsController, type: :controller do
  let(:geography) { create(:geography, name: 'Poland', iso: 'POL') }
  let(:sector) { create(:laws_sector, name: 'Airlines') }
  let!(:target1) {
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
      ]
    )
  }
  let!(:target2) {
    create(:target, :published, sector: sector, geography: geography, description: 'Example Description')
  }
  let!(:target3) {
    create(:target, :published, sector: sector, geography: geography, description: 'Example')
  }
  let!(:target4) {
    create(:target, :draft, sector: sector, geography: geography, description: 'This one is unpublished example')
  }

  before do
    create(:target_event, eventable: target1,  date: Date.parse('2018-04-03'))
    create(:target_event, eventable: target1,  date: Date.parse('2018-03-02'))

    create(:target_event, eventable: target2,  date: Date.parse('2019-03-02'))
    create(:target_event, eventable: target2,  date: Date.parse('2019-05-01'))

    create(:target_event, eventable: target3,  date: Date.parse('2018-03-03'))
    create(:target_event, eventable: target3,  date: Date.parse('2018-05-01'))
  end

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
        expect(response.body).to match_snapshot('cclow_climate_targets_controller_csv')
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
