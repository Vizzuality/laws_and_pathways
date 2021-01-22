require 'rails_helper'

RSpec.describe Admin::InstrumentTypesController, type: :controller do
  let_it_be(:admin) { create(:admin_user) }
  before { sign_in admin }

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
