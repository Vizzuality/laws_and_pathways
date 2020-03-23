require 'rails_helper'

RSpec.describe CCLOW::Api::TargetsController, type: :controller do
  let_it_be(:geography) { create(:geography, iso: 'ABC') }
  let_it_be(:geography2) { create(:geography, iso: 'DEF') }
  let_it_be(:geography3) { create(:geography, iso: 'GHI') }
  let_it_be(:sector1) { create(:laws_sector) }
  let_it_be(:sector2) { create(:laws_sector) }
  let_it_be(:sector3) { create(:laws_sector) }
  let_it_be(:legislation) { create(:legislation, laws_sectors: []) }
  let_it_be(:target1) { create(:target, year: 2025, geography_id: geography.id, sector: sector1) }
  let_it_be(:target2) { create(:target, year: 2020, geography_id: geography.id, sector: sector1) }
  let_it_be(:target3) { create(:target, geography_id: geography2.id, sector: sector2, legislations: [legislation]) }

  describe 'Get index with geography iso as param' do
    subject { get :index, params: {iso: geography.iso} }

    it { is_expected.to be_successful }

    it('should return all targets for that country') do
      subject
      result = JSON.parse(response.body)
      expect(result['targets'].size).to eq(2)
      expect(result['targets'].first['iso_code3']).to eq(geography.iso)
      expect(result['targets'].first['sector']).to eq(target2.sector.name.downcase)
      expect(result['sectors'].size).to eq(3)
    end
  end

  describe 'Get index with geography without targets' do
    subject { get :index, params: {iso: 'GHI'} }

    it { is_expected.to be_successful }

    it('should return no targets') do
      subject
      result = JSON.parse(response.body)
      expect(result['targets'].size).to eq(0)
      expect(result['sectors'].size).to eq(3)
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
