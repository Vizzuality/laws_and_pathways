require 'rails_helper'

RSpec.describe CCLOW::LitigationCasesController, type: :controller do
  before do
    create(:litigation, :published, title: 'Super Litigation')
    create(:litigation, :published, summary: 'Example description')
    create(:litigation, :published, title: 'Example')
    create(:litigation, :draft, title: 'This one is unpublished', summary: 'Example')
  end

  describe 'GET index' do
    context 'without filters' do
      subject { get :index }

      it { is_expected.to be_successful }

      it('should return all published litigations') do
        subject
        expect(assigns(:litigations).size).to eq(3)
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
      let(:params) { {q: 'example'} }
      subject { get :index, params: params }

      it { is_expected.to be_successful }

      it 'should return litigations' do
        subject
        expect(assigns(:litigations).size).to eq(2)
      end

      it 'responds to csv' do
        get :index, params: params, format: :csv
        expect(response.content_type).to eq('text/csv')
      end
    end
  end
end
