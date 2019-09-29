require 'rails_helper'

RSpec.describe Admin::InstrumentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  before { sign_in admin }

  describe 'DELETE destroy' do
    let!(:instrument) { create(:instrument, discarded_at: nil) }

    context 'with valid pspec/factories/instrument_types.rb:16arams' do
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
        expect(::Command::Destroy::Instrument).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_instruments_path)
        expect(flash[:alert]).to match('Could not delete selected Instrument')
      end
    end
  end
end
