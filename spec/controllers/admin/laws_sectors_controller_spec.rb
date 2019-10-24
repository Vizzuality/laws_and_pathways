require 'rails_helper'

RSpec.describe Admin::LawsSectorsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:sector) { create(:laws_sector) }
  let(:valid_attributes) { attributes_for(:laws_sector) }
  let(:invalid_attributes) { valid_attributes.merge(name: nil) }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    before(:example) do
      get :show, params: {id: sector.id}
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
    subject { get :edit, params: {id: sector.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {laws_sector: valid_attributes} }

      it 'creates a new Sector' do
        expect { subject }.to change(LawsSector, :count).by(1)
      end

      it 'redirects to the created Sector' do
        expect(subject).to redirect_to(admin_laws_sector_path(LawsSector.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {laws_sector: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Sector' do
        expect { subject }.not_to change(LawsSector, :count)
      end
    end
  end
end
