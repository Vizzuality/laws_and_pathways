require 'rails_helper'

RSpec.describe Admin::ASCORBenchmarksController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:ascor_country) { create :ascor_country, name: 'TEST', iso: 'TEST' }
  let_it_be(:ascor_benchmark) { create(:ascor_benchmark) }
  let(:valid_attributes) { attributes_for(:ascor_benchmark).merge country_id: ascor_country.id }
  let(:invalid_attributes) { valid_attributes.merge country_id: nil }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: ascor_benchmark.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: ascor_benchmark.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {ascor_benchmark: valid_attributes} }

      it 'creates a new ASCOR Benchmark' do
        expect { subject }.to change(ASCOR::Benchmark, :count).by(1)
      end

      it 'redirects to the created Benchmark' do
        expect(subject).to redirect_to(admin_ascor_benchmark_path(ASCOR::Benchmark.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {ascor_benchmark: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not create a ASCOR Benchmark' do
        expect { subject }.not_to change(ASCOR::Benchmark, :count)
      end
    end
  end

  describe 'PUT update' do
    context 'with valid params' do
      subject { put :update, params: {id: ascor_benchmark.id, ascor_benchmark: valid_attributes} }

      it 'updates the requested benchmark' do
        expect { subject }.to change { ascor_benchmark.reload.country_id }.to(ascor_country.id)
      end

      it 'redirects to the benchmark' do
        expect(subject).to redirect_to(admin_ascor_benchmark_path(ascor_benchmark))
      end
    end

    context 'with invalid params' do
      subject { put :update, params: {id: ascor_benchmark.id, ascor_benchmark: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not update the requested benchmark' do
        expect { subject }.not_to change(ascor_benchmark.reload, :country_id)
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: {id: ascor_benchmark.id} }

    it 'destroys the requested benchmark' do
      expect { subject }.to change(ASCOR::Benchmark, :count).by(-1)
    end

    it 'redirects to the benchmarks list' do
      expect(subject).to redirect_to(admin_ascor_benchmarks_path)
    end
  end
end
