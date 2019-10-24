require 'rails_helper'

RSpec.describe Admin::MQAssessmentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:mq_assessment) { create(:mq_assessment) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: mq_assessment.id} }

    it { is_expected.to be_successful }
  end
end
