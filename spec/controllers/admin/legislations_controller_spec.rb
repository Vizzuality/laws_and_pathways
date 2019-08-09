require 'rails_helper'

RSpec.describe Admin::LegislationsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:geography) { create(:geography) }

  let!(:legislation) { create(:legislation) }
  let(:valid_attributes) {
    attributes_for(:legislation).merge(
      geography_id: geography.id
    )
  }

  let(:invalid_attributes) { valid_attributes.merge(title: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: legislation.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: legislation.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {legislation: valid_attributes} }

      it 'creates a new Legislation' do
        expect { subject }.to change(Legislation, :count).by(1)
      end

      it 'redirects to the created Legislation' do
        expect(subject).to redirect_to(admin_legislation_path(Legislation.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {legislation: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Litigation' do
        expect { subject }.not_to change(Legislation, :count)
      end
    end
  end
end
