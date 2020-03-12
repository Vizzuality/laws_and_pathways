require 'rails_helper'

RSpec.describe TPI::HomeController, type: :controller do
  before do
    create(:publication)
    create(:publication)
    create(:news_article)
  end

  describe 'GET index' do
    context 'my index page' do
      subject { get :index }

      it { is_expected.to be_successful }
    end
  end
end
