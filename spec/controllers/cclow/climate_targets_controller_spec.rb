require 'rails_helper'

RSpec.describe CCLOW::ClimateTargetsController, type: :controller do
  before do
    create(:target, :published, description: 'Super Litigation')
    create(:target, :published, description: 'Example description')
    create(:target, :published, description: 'Example')
    create(:target, :draft, description: 'This one is unpublished example')
  end

  describe 'GET index' do
    context 'without filters' do
      subject { get :index }

      it { is_expected.to be_successful }

      it('should return all published targets') do
        subject
        expect(assigns(:climate_targets).size).to eq(3)
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
