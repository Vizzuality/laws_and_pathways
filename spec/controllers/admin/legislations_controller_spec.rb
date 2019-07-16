require 'rails_helper'

RSpec.describe Admin::LegislationsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:legislation) { create(:legislation) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: legislation.id} }

    it { is_expected.to be_successful }
  end
end
