require 'rails_helper'

RSpec.describe Admin::CPBenchmarksController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:sector) { create(:tpi_sector, :with_benchmarks) }
  let(:benchmark) { sector.cp_benchmarks.first }
  let(:valid_attributes) { attributes_for(:cp_benchmark, sector_id: sector.id) }
  let(:invalid_attributes) { valid_attributes.merge(scenario: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: benchmark.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: benchmark.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {cp_benchmark: valid_attributes} }

      it 'creates a new Benchmark' do
        expect { subject }.to change(CP::Benchmark, :count).by(1)
      end

      it 'redirects to the created Benchmark' do
        expect(subject).to redirect_to(admin_cp_benchmark_path(CP::Benchmark.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {cp_benchmark: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Benchmark' do
        expect { subject }.not_to change(CP::Benchmark, :count)
      end
    end
  end
end
