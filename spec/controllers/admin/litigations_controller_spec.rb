require 'rails_helper'

RSpec.describe Admin::LitigationsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:litigation) { create(:litigation, :with_sides ) }
  let(:side_location) { create(:location) }
  let(:side_company) { create(:company) }
  let(:location) { create(:location) }
  let(:valid_attributes) {
    attributes_for(:litigation).merge(
      location_id: location.id,
      jurisdiction_id: location.id,
      litigation_sides_attributes: [
        attributes_for(:litigation_side),
        attributes_for(:litigation_side, :company).merge(
          connected_with: "Company-#{side_company.id}"
        ),
        attributes_for(:litigation_side, :location).merge(
          connected_with: "Location-#{side_location.id}"
        )
      ],
      documents_attributes: [
        attributes_for(:document),
        attributes_for(:document_uploaded)
      ]
    )
  }
  let(:invalid_attributes) { valid_attributes.merge(title: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: litigation.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: litigation.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {litigation: valid_attributes} }

      it 'creates a new Litigation' do
        expect { subject }.to change(Litigation, :count).by(1)
      end

      it 'redirects to the created Litigation' do
        expect(subject).to redirect_to(admin_litigation_path(Litigation.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {litigation: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Litigation' do
        expect { subject }.not_to change(Litigation, :count)
      end
    end
  end
end
