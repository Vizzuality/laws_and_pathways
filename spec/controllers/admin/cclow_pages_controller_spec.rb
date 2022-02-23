require 'rails_helper'

RSpec.describe Admin::CCLOWPagesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let_it_be(:page) { create(:cclow_page) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: page.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: page.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) do
        attributes_for(
          :cclow_page,
          title: 'My amazing title',
          description: 'Test short_description',
          contents_attributes: [
            attributes_for(:content, text: 'text1', content_type: 'regular'),
            attributes_for(
              :content,
              text: 'text2',
              content_type: 'text_description',
              images_attributes: [attributes_for(:image, name: 'image1', link: 'https://example.com')]
            )
          ]
        )
      end

      subject { post :create, params: {cclow_page: valid_params} }

      it 'creates a new CCLOW Page' do
        expect { subject }.to change(CCLOWPage, :count).by(1)

        last_page_created.tap do |p|
          expect(p.title).to eq(valid_params[:title])
          expect(p.description).to eq(valid_params[:description])
          expect(p.contents.pluck(:text, :content_type)).to eq([
                                                                 %w(text1 regular),
                                                                 %w(text2 text_description)
                                                               ])
          expect(p.images.count).to eq(1)
          expect(p.images[0].name).to eq('image1')
          expect(p.images[0].link).to eq('https://example.com')
          expect(p.images[0].logo.attached?).to be(true)
        end
      end

      it 'redirects to the created Page' do
        expect(subject).to redirect_to(admin_cclow_page_path(last_page_created))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:cclow_page, title: nil) }

      subject { post :create, params: {cclow_page: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a Page' do
        expect { subject }.not_to change(CCLOWPage, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:page_to_update) { create(:cclow_page) }

    context 'with valid params' do
      let(:valid_update_params) { {title: 'title was updated'} }

      subject { patch :update, params: {id: page_to_update.id, cclow_page: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(CCLOWPage, :count)
      end

      it 'updates existing Page' do
        expect { subject }.to change { page_to_update.reload.title }.to('title was updated')
      end

      it 'redirects to the updated Page' do
        expect(subject).to redirect_to(admin_cclow_page_path(page_to_update))
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:page_to_delete) { create(:cclow_page) }

    context 'with valid params' do
      let(:id_to_delete) { page_to_delete.id }

      subject { delete :destroy, params: {id: page_to_delete.id} }

      it 'deletes Page' do
        # should disappear from default scope
        expect { subject }.to change { CCLOWPage.count }.by(-1)
        expect(CCLOWPage.find_by_id(id_to_delete)).to be_nil

        expect(flash[:notice]).to match('Page was successfully destroyed.')
      end
    end
  end

  def last_page_created
    CCLOWPage.order(:created_at).last
  end
end
