require 'rails_helper'

RSpec.describe TPI::MQAssessmentsController, type: :controller do
  describe 'GET enable_beta_data' do
    before { get :enable_beta_data }

    it 'gets redirected to the root url' do
      expect(response).to redirect_to(tpi_root_url)
    end

    it 'sets the session' do
      expect(session['enable_beta_mq_assessments']).to be_truthy
    end
  end

  describe 'GET disable_beta_data' do
    before { get :disable_beta_data }

    it 'gets redirected to the root url' do
      expect(response).to redirect_to(tpi_root_url)
    end

    it 'sets the session' do
      expect(session['enable_beta_mq_assessments']).to be_falsey
    end
  end
end
