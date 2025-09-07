require 'rails_helper'

RSpec.describe Admin::InstrumentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  before { sign_in admin }
  let_it_be(:instrument_type) { create(:instrument_type) }
  let_it_be(:instrument) { create(:instrument, instrument_type: instrument_type) }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: instrument.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: instrument.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) do
        attributes_for(:instrument).merge(instrument_type_id: instrument_type.id)
      end

      subject { post :create, params: {instrument: valid_params} }

      it 'creates a new Instrument' do
        expect { subject }.to change(Instrument, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:instrument, name: nil) }

      subject { post :create, params: {instrument: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create an instrument' do
        expect { subject }.not_to change(Instrument, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:instrument_to_update) { create(:instrument) }

    context 'with valid params' do
      let(:valid_update_params) { {name: 'name was updated'} }

      subject { patch :update, params: {id: instrument_to_update.id, instrument: valid_update_params} }

      it 'updates existing Instrument' do
        expect { subject }.to change { instrument_to_update.reload.name }.to('name was updated')
      end
    end
  end

  describe 'DELETE destroy' do
    render_views false

    let!(:instrument) { create(:instrument, discarded_at: nil) }

    context 'with valid params' do
      subject { delete :destroy, params: {id: instrument.id} }

      before do
        expect { subject }.to change { Instrument.count }.by(-1)
      end

      it 'set discarded_at date to instrument object' do
        expect(instrument.reload.discarded_at).to_not be_nil
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected Instrument')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: instrument.id} }

      before do
        expect(Command::Destroy::Instrument).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_instruments_path)
        expect(flash[:alert]).to match('Could not delete selected Instrument')
      end
    end
  end
end
