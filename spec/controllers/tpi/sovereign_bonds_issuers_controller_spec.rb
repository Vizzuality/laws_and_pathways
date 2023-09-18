require 'rails_helper'

RSpec.describe TPI::SovereignBondsIssuersController, type: :controller do
  let_it_be(:ascor_country) { create :ascor_country }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: ascor_country.slug} }

    it { is_expected.to be_successful }
  end

  describe 'GET user download' do
    subject { get :user_download }

    it { is_expected.to be_successful }
  end
end
