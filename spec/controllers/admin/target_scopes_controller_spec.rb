require 'rails_helper'

RSpec.describe Admin::TargetScopesController, type: :controller do
  let(:admin) { create(:admin_user) }
  before { sign_in admin }

  describe 'DELETE destroy' do
    let!(:target_scope) { create(:target_scope, discarded_at: nil) }

    context 'with valid params' do
      subject { delete :destroy, params: {id: target_scope.id} }

      before do
        expect { subject }.to change { TargetScope.count }.by(-1)
      end

      it 'set discarded_at date to target scope object' do
        expect(target_scope.reload.discarded_at).to_not be_nil
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected TargetScope')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: target_scope.id} }

      before do
        expect(::Command::Destroy::TargetScope).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_target_scopes_path)
        expect(flash[:alert]).to match('Could not delete selected TargetScope')
      end
    end
  end
end
