require 'rails_helper'

RSpec.describe CCLOW::ClimateTargetsController, type: :controller do
  let!(:target1) { create(:target, :published, description: 'Super target') }
  let!(:target2) { create(:target, :published, description: 'Example Description') }
  let!(:target3) { create(:target, :published, description: 'Example') }
  let!(:target4) { create(:target, :draft, description: 'This one is unpublished example') }

  before do
    create(:target_event, eventable: target1, date: 30.days.ago)
    create(:target_event, eventable: target1, date: 50.days.ago)

    create(:target_event, eventable: target2, date: 40.days.ago)
    create(:target_event, eventable: target2, date: 10.days.ago)

    create(:target_event, eventable: target3, date: 30.days.ago)
    create(:target_event, eventable: target3, date: 20.days.ago)
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
