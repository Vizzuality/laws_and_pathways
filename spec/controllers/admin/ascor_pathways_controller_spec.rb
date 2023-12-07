require 'rails_helper'

RSpec.describe Admin::ASCORPathwaysController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:ascor_country) { create :ascor_country, name: 'TEST', iso: 'TEST' }
  let_it_be(:ascor_pathway) { create(:ascor_pathway) }
  let(:valid_attributes) { attributes_for(:ascor_pathway).merge country_id: ascor_country.id }
  let(:invalid_attributes) { valid_attributes.merge country_id: nil }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: ascor_pathway.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: ascor_pathway.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {ascor_pathway: valid_attributes} }

      it 'creates a new ASCOR Pathway' do
        expect { subject }.to change(ASCOR::Pathway, :count).by(1)
      end

      it 'redirects to the created Pathway' do
        expect(subject).to redirect_to(admin_ascor_pathway_path(ASCOR::Pathway.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {ascor_pathway: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not create a ASCOR Pathway' do
        expect { subject }.not_to change(ASCOR::Pathway, :count)
      end
    end
  end

  describe 'PUT update' do
    context 'with valid params' do
      subject { put :update, params: {id: ascor_pathway.id, ascor_pathway: valid_attributes} }

      it 'updates the requested pathway' do
        expect { subject }.to change { ascor_pathway.reload.country_id }.to(ascor_country.id)
      end

      it 'redirects to the pathway' do
        expect(subject).to redirect_to(admin_ascor_pathway_path(ascor_pathway))
      end
    end

    context 'with invalid params' do
      subject { put :update, params: {id: ascor_pathway.id, ascor_pathway: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes does not update the ASCOR Pathway' do
        expect { subject }.not_to change(ascor_pathway.reload, :country_id)
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: {id: ascor_pathway.id} }

    it 'destroys the requested pathway' do
      expect { subject }.to change(ASCOR::Pathway, :count).by(-1)
    end

    it 'redirects to the pathways list' do
      expect(subject).to redirect_to(admin_ascor_pathways_path)
    end
  end
end
