require 'rails_helper'

RSpec.describe Admin::LocationsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:location) { create(:location) }
  let(:valid_attributes) { attributes_for(:location) }
  let(:invalid_attributes) { valid_attributes.merge(iso: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: location.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: location.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {location: valid_attributes} }

      it 'creates a new Location' do
        expect { subject }.to change(Location, :count).by(1)
      end

      it 'redirects to the created Location' do
        expect(subject).to redirect_to(admin_location_path(Location.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {location: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Location' do
        expect { subject }.not_to change(Location, :count)
      end
    end
  end
end
