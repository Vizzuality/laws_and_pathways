require 'rails_helper'

RSpec.describe Admin::InstrumentTypesController, type: :controller do
  let(:admin) { create(:admin_user) }
  before { sign_in admin }
  let_it_be(:instrument_type) { create(:instrument_type) }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: instrument_type.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: instrument_type.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) { attributes_for(:instrument_type) }

      subject { post :create, params: {instrument_type: valid_params} }

      it 'creates a new Instrument Type' do
        expect { subject }.to change(InstrumentType, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:instrument_type, name: nil) }

      subject { post :create, params: {instrument_type: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create an instrument type' do
        expect { subject }.not_to change(InstrumentType, :count)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:instrument_type) { create(:instrument_type, discarded_at: nil) }

    context 'with valid params' do
      subject { delete :destroy, params: {id: instrument_type.id} }

      before do
        expect { subject }.to change { InstrumentType.count }.by(-1)
      end

      it 'set discarded_at date to instrument type object' do
        expect(instrument_type.reload.discarded_at).to_not be_nil
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected InstrumentType')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: instrument_type.id} }

      before do
        expect(::Command::Destroy::InstrumentType).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_instrument_types_path)
        expect(flash[:alert]).to match('Could not delete selected InstrumentType')
      end
    end
  end
end
