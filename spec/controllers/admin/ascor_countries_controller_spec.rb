require 'rails_helper'

RSpec.describe Admin::ASCORCountriesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:ascor_country) { create(:ascor_country) }
  let(:valid_attributes) { attributes_for(:ascor_country).merge name: 'TEST', iso: 'TEST' }
  let(:invalid_attributes) { valid_attributes.merge(name: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: ascor_country.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: ascor_country.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {ascor_country: valid_attributes} }

      it 'creates a new ASCOR Country' do
        expect { subject }.to change(ASCOR::Country, :count).by(1)
      end

      it 'redirects to the created Country' do
        expect(subject).to redirect_to(admin_ascor_country_path(ASCOR::Country.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {ascor_country: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not create a ASCOR Country' do
        expect { subject }.not_to change(ASCOR::Country, :count)
      end
    end
  end

  describe 'PUT update' do
    context 'with valid params' do
      subject { put :update, params: {id: ascor_country.id, ascor_country: valid_attributes} }

      it 'updates the requested ASCOR Country' do
        expect { subject }.to change { ascor_country.reload.name }.to(valid_attributes[:name])
      end

      it 'redirects to the ASCOR Country' do
        expect(subject).to redirect_to(admin_ascor_country_path(ascor_country))
      end
    end

    context 'with invalid params' do
      subject { put :update, params: {id: ascor_country.id, ascor_country: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not update the ASCOR Country' do
        expect { subject }.not_to change(ascor_country.reload, :name)
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: {id: ascor_country.id} }

    it 'destroys the requested ASCOR Country' do
      expect { subject }.to change(ASCOR::Country, :count).by(-1)
    end

    it 'redirects to the ASCOR Countries list' do
      expect(subject).to redirect_to(admin_ascor_countries_path)
    end
  end
end
