require 'rails_helper'

RSpec.describe Admin::BanksController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:geography) { create(:geography) }
  let_it_be(:bank) { create(:bank, geography: geography) }
  let(:valid_attributes) {
    attributes_for(:bank).merge(geography_id: geography.id)
  }
  let(:invalid_attributes) { valid_attributes.merge(isin: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET index with .csv format' do
    before :each do
      get :index, format: 'csv'
    end

    it('returns CSV file') do
      expect(response.header['Content-Type']).to include('text/csv')
    end
  end

  describe 'GET show' do
    subject { get :show, params: {id: bank.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: bank.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {bank: valid_attributes} }

      it 'creates a new Bank' do
        expect { subject }.to change(Bank, :count).by(1)
      end

      it 'redirects to the created Bank' do
        expect(subject).to redirect_to(admin_bank_path(Bank.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {bank: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Bank' do
        expect { subject }.not_to change(Bank, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:bank_to_update) { create(:bank, geography: geography) }

    context 'with valid params' do
      let(:valid_update_params) { {name: 'name was updated'} }

      subject { patch :update, params: {id: bank_to_update.id, bank: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(Bank, :count)
      end

      it 'updates existing Bank' do
        expect { subject }.to change { bank_to_update.reload.name }.to('name was updated')
      end

      it 'creates "edited" activity' do
        expect { subject }.to change(PublicActivity::Activity, :count).by(1)

        expect(PublicActivity::Activity.last.trackable_id).to eq(bank_to_update.id)
        expect(PublicActivity::Activity.last.key).to eq('bank.edited')
      end

      it 'redirects to the updated Bank' do
        expect(subject).to redirect_to(admin_bank_path(bank_to_update))
      end
    end
  end

  describe 'DELETE destroy' do
    render_views false

    let!(:bank) { create(:bank, geography: geography) }

    subject { delete :destroy, params: {id: bank.id} }

    before do
      expect { subject }.to change { Bank.count }.by(-1)
    end

    it 'shows proper notice' do
      expect(flash[:notice]).to match('Bank was successfully destroyed.')
    end
  end
end
