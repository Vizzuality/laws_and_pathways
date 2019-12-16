require 'rails_helper'

RSpec.describe CCLOW::ClimateTargetsController, type: :controller do
  let!(:geography) { create(:geography, iso: 'ABC') }
  let!(:target1) {
    create(:target,
           year: 2025, geography_id: geography.id,
           description: 'Sumol', visibility_status: 'published')
  }
  let!(:target2) {
    create(:target,
           year: 2020, geography_id: geography.id,
           description: 'Coca Cola', visibility_status: 'published')
  }

  describe 'Get index with query param without matches' do
    subject { get :index, params: {q: 'Compal'} }

    it { is_expected.to be_successful }

    it('should return no targets') do
      subject
      expect(assigns(:climate_targets).size).to eq(0)
    end
  end

  describe 'Get index with query param with matches' do
    subject { get :index, params: {q: 'Sumol'} }

    it { is_expected.to be_successful }

    it('should return targets') do
      subject
      expect(assigns(:climate_targets).size).to eq(1)
    end
  end
end
