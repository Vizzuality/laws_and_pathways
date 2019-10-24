require 'rails_helper'

RSpec.describe Admin::CPAssessmentsController, type: :controller do
  let(:admin) { create(:admin_user) }
  let!(:cp_assessment) { create(:cp_assessment) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: cp_assessment.id} }

    it { is_expected.to be_successful }
  end
end
