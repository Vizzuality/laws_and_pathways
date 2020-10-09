require 'rails_helper'

RSpec.describe TPI::HomeController, type: :controller do
  let_it_be(:publication1) { create(:publication, publication_date: 2.days.ago) }
  let_it_be(:news_article1) { create(:news_article, publication_date: 3.days.ago) }
  let_it_be(:publication2) { create(:publication, publication_date: 12.days.ago) }
  let_it_be(:news_article2) { create(:news_article, publication_date: 13.days.ago) }
  let_it_be(:publication3) { create(:publication, publication_date: 14.days.ago) }
  let_it_be(:publication4) { create(:publication, publication_date: 3.days.from_now) }
  let_it_be(:news_article3) { create(:news_article, publication_date: 15.days.ago) }
  let_it_be(:news_article4) { create(:news_article, publication_date: 4.days.from_now) }

  describe 'GET index' do
    context 'my index page' do
      subject { get :index }

      it { is_expected.to be_successful }

      it 'assigns publications and articles' do
        subject

        expect(assigns(:publications_and_articles)).to match_array [publication1, news_article1, publication2]
      end
    end
  end
end
