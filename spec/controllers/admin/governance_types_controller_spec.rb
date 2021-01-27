require 'rails_helper'

RSpec.describe Admin::GovernanceTypesController, type: :controller do
  let_it_be(:admin) { create(:admin_user) }
  before { sign_in admin }

  describe 'DELETE destroy' do
    let!(:governance_type) { create(:governance_type, discarded_at: nil) }

    context 'with valid params' do
      subject { delete :destroy, params: {id: governance_type.id} }

      before do
        expect { subject }.to change { GovernanceType.count }.by(-1)
      end

      it 'set discarded_at date to governance type object' do
        expect(governance_type.reload.discarded_at).to_not be_nil
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected GovernanceType')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: governance_type.id} }

      before do
        expect(::Command::Destroy::GovernanceType).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_governance_types_path)
        expect(flash[:alert]).to match('Could not delete selected GovernanceType')
      end
    end
  end
end
