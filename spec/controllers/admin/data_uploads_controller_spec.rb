require 'rails_helper'

RSpec.describe Admin::DataUploadsController, type: :controller do
  let(:admin) { create(:admin_user) }
  before { sign_in admin }
  let_it_be(:data_upload) { create(:data_upload) }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: data_upload.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end
end
