require 'rails_helper'

RSpec.describe Admin::GovernancesController, type: :controller do
  let(:admin) { create(:admin_user) }
  before { sign_in admin }

  describe 'DELETE destroy' do
    let!(:governance) { create(:governance, discarded_at: nil) }

    context 'with valid params' do
      subject { delete :destroy, params: {id: governance.id} }

      before do
        expect { subject }.to change { Governance.count }.by(-1)
      end

      it 'set discarded_at date to governance object' do
        expect(governance.reload.discarded_at).to_not be_nil
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected Governance')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: governance.id} }

      before do
        expect(::Command::Destroy::Governance).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_governances_path)
        expect(flash[:alert]).to match('Could not delete selected Governance')
      end
    end
  end
end
