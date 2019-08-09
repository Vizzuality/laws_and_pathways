require 'rails_helper'

RSpec.describe Admin::GeographiesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:geography) { create(:geography) }
  let(:valid_attributes) { attributes_for(:geography) }
  let(:invalid_attributes) { valid_attributes.merge(iso: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: geography.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: geography.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {geography: valid_attributes} }

      it 'creates a new Geography' do
        expect { subject }.to change(Geography, :count).by(1)
      end

      it 'redirects to the created Geography' do
        expect(subject).to redirect_to(admin_geography_path(Geography.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {geography: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Geography' do
        expect { subject }.not_to change(Geography, :count)
      end
    end
  end
end
