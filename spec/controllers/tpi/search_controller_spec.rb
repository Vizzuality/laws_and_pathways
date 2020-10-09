require 'rails_helper'

RSpec.describe TPI::SearchController, type: :controller do
  let_it_be(:sector1) { create(:tpi_sector, name: 'Economy') }
  let_it_be(:sector2) { create(:tpi_sector, name: 'Energy') }
  let_it_be(:company1) { create(:company, :published, name: 'Energy company') }
  let_it_be(:company2) { create(:company, :published, name: 'Hitachi') }
  let_it_be(:company3) { create(:company, :pending, name: 'Energy 2 company') }
  let_it_be(:publication1) { create(:publication, :published, title: 'Energy is the title') }
  let_it_be(:publication2) { create(:publication, :published, short_description: 'energy in description') }
  let_it_be(:publication3) { create(:publication, :published) }
  let_it_be(:publication4) { create(:publication, title: 'Energy not published', publication_date: 3.days.from_now) }
  let_it_be(:news_article1) { create(:news_article, :published, title: 'The title with Energyin it') }
  let_it_be(:news_article2) { create(:news_article, :published, content: 'Content with energy') }
  let_it_be(:news_article3) { create(:news_article, :published) }
  let_it_be(:news_article4) { create(:news_article, title: 'Energy but not published', publication_date: 4.days.from_now) }

  describe 'GET index' do
    context 'without query' do
      subject { get :index }

      it { is_expected.to be_successful }
      it 'does not assing any results' do
        subject
        expect(assigns(:sectors)).to be_empty
        expect(assigns(:companies)).to be_empty
        expect(assigns(:publications_and_articles)).to be_empty
      end
    end

    context 'with query having matches' do
      subject { get :index, params: {query: 'energy'} }

      it { is_expected.to be_successful }
      it 'does assing results' do
        subject
        expect(assigns(:sectors)).to contain_exactly(sector2)
        expect(assigns(:companies)).to contain_exactly(company1)
        expect(assigns(:publications_and_articles)).to contain_exactly(
          publication1,
          publication2,
          news_article1,
          news_article2
        )
      end
    end

    context 'with query not having matches' do
      subject { get :index, params: {query: 'Non exising'} }

      it { is_expected.to be_successful }
      it 'does not assing any results' do
        subject
        expect(assigns(:sectors)).to be_empty
        expect(assigns(:companies)).to be_empty
        expect(assigns(:publications_and_articles)).to be_empty
      end
    end
  end
end
