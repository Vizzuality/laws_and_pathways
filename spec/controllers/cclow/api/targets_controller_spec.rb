require 'rails_helper'

RSpec.describe CCLOW::Api::TargetsController, type: :controller do
  let!(:geography) { create(:geography, iso: 'ABC') }
  let!(:geography2) { create(:geography, iso: 'DEF') }
  let!(:geography3) { create(:geography, iso: 'GHI') }
  let!(:target1) { create(:target, year: 2025, geography_id: geography.id) }
  let!(:target2) { create(:target, year: 2020, geography_id: geography.id) }
  let!(:target3) { create(:target, geography_id: geography2.id) }

  describe 'Get index with geography iso as param' do
    subject { get :index, params: {iso: geography.iso} }

    it { is_expected.to be_successful }

    it('should return all targets for that country') do
      subject
      result = JSON.parse(response.body)
      expect(result.size).to eq(2)
      expect(result.first['iso_code3']).to eq(geography.iso)
      expect(result.first['sector']).to eq(target2.sector.name)
    end
  end

  describe 'Get index with geography without targets' do
    subject { get :index, params: {iso: 'GHI'} }

    it { is_expected.to be_successful }

    it('should return no targets') do
      subject
      result = JSON.parse(response.body)
      expect(result.size).to eq(0)
    end
  end

  describe 'return 404 if no Geography exist' do
    subject { get :index, params: {iso: 'LKM'} }

    it('should return error message') do
      subject
      result = JSON.parse(response.body)
      expect(result['error']).to eq('not-found')
    end
  end
end
