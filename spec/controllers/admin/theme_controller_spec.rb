require 'rails_helper'

RSpec.describe Admin::ThemesController, type: :controller do
  let(:admin) { create(:admin_user) }
  before { sign_in admin }

  describe 'DELETE destroy' do
    let!(:theme) { create(:theme, discarded_at: nil) }

    context 'with valid params' do
      subject { delete :destroy, params: {id: theme.id} }

      before do
        expect { subject }.to change { Theme.count }.by(-1)
      end

      it 'set discarded_at date to theme object' do
        expect(theme.reload.discarded_at).to_not be_nil
      end

      it 'shows proper notice' do
        expect(flash[:notice]).to match('Successfully deleted selected Theme')
      end
    end

    context 'with invalid params' do
      let(:command) { double }

      subject { delete :destroy, params: {id: theme.id} }

      before do
        expect(::Command::Destroy::Theme).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_themes_path)
        expect(flash[:alert]).to match('Could not delete selected Theme')
      end
    end
  end
end
