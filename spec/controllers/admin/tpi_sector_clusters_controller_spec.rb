require 'rails_helper'

RSpec.describe Admin::TPISectorClustersController, type: :controller do
  let_it_be(:admin) { create(:admin_user) }
  let_it_be(:cluster) { create(:tpi_sector_cluster) }
  let(:valid_attributes) { attributes_for(:tpi_sector_cluster) }
  let(:invalid_attributes) { valid_attributes.merge(name: nil) }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    before(:example) do
      get :show, params: {id: cluster.id}
    end

    it 'should be successful' do
      expect(response).to be_successful
    end
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: cluster.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {tpi_sector_cluster: valid_attributes} }

      it 'creates a new Sector' do
        expect { subject }.to change(TPISectorCluster, :count).by(1)
      end

      it 'redirects to the created Cluster' do
        expect(subject).to redirect_to(admin_tpi_sector_cluster_path(TPISectorCluster.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {tpi_sector_cluster: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Cluster' do
        expect { subject }.not_to change(TPISectorCluster, :count)
      end
    end
  end
end
