require 'rails_helper'

RSpec.describe Admin::ThemesController, type: :controller do
  let(:admin) { create(:admin_user) }
  before { sign_in admin }
  let_it_be(:theme_type) { create(:theme_type) }
  let_it_be(:theme) { create(:theme, theme_type: theme_type) }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: theme.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: theme.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) do
        attributes_for(:theme).merge(theme_type_id: theme_type.id)
      end

      subject { post :create, params: {theme: valid_params} }

      it 'creates a new Theme' do
        expect { subject }.to change(Theme, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:theme, name: nil) }

      subject { post :create, params: {theme: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create an theme' do
        expect { subject }.not_to change(Theme, :count)
      end
    end
  end

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
        expect(Command::Destroy::Theme).to receive(:new).and_return(command)
        expect(command).to receive(:call).and_return(nil)
      end

      it 'redirects to index & renders alert message' do
        expect(subject).to redirect_to(admin_themes_path)
        expect(flash[:alert]).to match('Could not delete selected Theme')
      end
    end
  end
end
