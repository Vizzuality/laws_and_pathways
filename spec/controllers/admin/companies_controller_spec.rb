require 'rails_helper'

RSpec.describe Admin::CompaniesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:company) { create(:company) }
  let(:sector) { create(:sector) }
  let(:location) { create(:location) }
  let(:valid_attributes) {
    attributes_for(:company).merge(
      location_id: location.id, headquarter_location_id: location.id, sector_id: sector.id
    )
  }
  let(:invalid_attributes) { valid_attributes.merge(isin: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: company.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: company.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {company: valid_attributes} }

      it 'creates a new Company' do
        expect { subject }.to change(Company, :count).by(1)
      end

      it 'redirects to the created Company' do
        expect(subject).to redirect_to(admin_company_path(Company.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {company: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Company' do
        expect { subject }.not_to change(Company, :count)
      end
    end
  end
end
