require 'rails_helper'

RSpec.describe Admin::NewsArticlesController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:news_article) { create(:news_article) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: news_article.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: news_article.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_params) do
        attributes_for(
          :news_article,
          title: 'My amazing title',
          content: 'Test Content'
        )
      end

      subject { post :create, params: {news_article: valid_params} }

      it 'creates a new NewsArticle' do
        expect { subject }.to change(NewsArticle, :count).by(1)

        last_news_article_created.tap do |g|
          expect(g.title).to eq(valid_params[:title])
          expect(g.content).to eq(valid_params[:content])
        end
      end

      it 'redirects to the created NewsArticle' do
        expect(subject).to redirect_to(admin_news_article_path(NewsArticle.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:news_article, title: nil) }

      subject { post :create, params: {news_article: invalid_params} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a NewsArticle' do
        expect { subject }.not_to change(NewsArticle, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:news_article_to_update) { create(:news_article) }

    context 'with valid params' do
      let(:valid_update_params) { {title: 'title was updated'} }

      subject { patch :update, params: {id: news_article_to_update.id, news_article: valid_update_params} }

      it 'does not create another record' do
        expect { subject }.not_to change(NewsArticle, :count)
      end

      it 'updates existing NewsArticle' do
        expect { subject }.to change { news_article_to_update.reload.title }.to('title was updated')
      end

      it 'creates "edited" activity' do
        expect { subject }.to change(PublicActivity::Activity, :count).by(1)

        expect(PublicActivity::Activity.last.trackable_id).to eq(news_article_to_update.id)
        expect(PublicActivity::Activity.last.key).to eq('news_article.edited')
      end

      it 'redirects to the updated NewsArticle' do
        expect(subject).to redirect_to(admin_news_article_path(news_article_to_update))
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:news_article_to_delete) { create(:news_article) }

    context 'with valid params' do
      let(:id_to_delete) { news_article_to_delete.id }

      subject { delete :destroy, params: {id: news_article_to_delete.id} }

      it 'deletes NewsArticle' do
        # should disappear from default scope
        expect { subject }.to change { NewsArticle.count }.by(-1)
        expect(NewsArticle.find_by_id(id_to_delete)).to be_nil

        expect(flash[:notice]).to match('News article was successfully destroyed.')
      end
    end
  end

  def last_news_article_created
    NewsArticle.order(:created_at).last
  end
end
