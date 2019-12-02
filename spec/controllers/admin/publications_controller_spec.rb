require 'rails_helper'

RSpec.describe Admin::PublicationsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:publication) { create(:publication) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: publication.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: publication.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) do
        attributes_for(
          :publication,
          title: 'My amazing title',
          short_description: 'Test short_description'
        )
      end

      subject { post :create, params: {publication: valid_params} }

      it 'creates a new Publication' do
        expect { subject }.to change(Publication, :count).by(1)

        last_publication_created.tap do |g|
          expect(g.title).to eq(valid_params[:title])
          expect(g.short_description).to eq(valid_params[:short_description])
        end
      end

      it 'redirects to the created Publication' do
        expect(subject).to redirect_to(admin_publication_path(Publication.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:publication, title: nil) }

      subject { post :create, params: {publication: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Publication' do
        expect { subject }.not_to change(Publication, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:publication_to_update) { create(:publication) }

    context 'with valid params' do
      let(:valid_update_params) { {title: 'title was updated'} }

      subject { patch :update, params: {id: publication_to_update.id, publication: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(Publication, :count)
      end

      it 'updates existing Publication' do
        expect { subject }.to change { publication_to_update.reload.title }.to('title was updated')
      end

      it 'creates "edited" activity' do
        expect { subject }.to change(PublicActivity::Activity, :count).by(1)

        expect(PublicActivity::Activity.last.trackable_id).to eq(publication_to_update.id)
        expect(PublicActivity::Activity.last.key).to eq('publication.edited')
      end

      it 'redirects to the updated Publication' do
        expect(subject).to redirect_to(admin_publication_path(publication_to_update))
      end
    end
  end

  def last_publication_created
    Publication.order(:created_at).last
  end
end
