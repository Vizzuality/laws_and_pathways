require 'rails_helper'

RSpec.describe Queries::CCLOW::LegislationQuery do
  let(:biodiversity) { create(:keyword, name: 'Biodiversity') }
  let(:business_risk) { create(:keyword, name: 'Business risk') }
  let(:cap_and_trade) { create(:keyword, name: 'Cap and Trade') }
  let(:adaptation) { create(:response, name: 'Adaptation') }
  let(:mitigation) { create(:response, name: 'Mitigation') }
  let(:sector1) { create(:laws_sector) }
  let(:sector2) { create(:laws_sector) }
  let(:sector3) { create(:laws_sector) }

  let!(:legislation1) {
    create(
      :legislation,
      :published,
      :executive,
      laws_sectors: [sector1, sector3],
      title: 'Union Budget 2019-2020',
      keywords: [biodiversity, cap_and_trade],
      responses: [adaptation],
      events: [
        build(:event, event_type: 'law_passed', date: '2010-01-01'),
        build(:event, event_type: 'amended', date: '2013-03-01')
      ]
    )
  }
  let!(:legislation2) {
    create(
      :legislation,
      :published,
      :legislative,
      laws_sectors: [sector1],
      title: 'Act No. 7 of 1994 on protection against natural damage',
      keywords: [business_risk, cap_and_trade],
      events: [
        build(:event, event_type: 'law_passed', date: '2014-12-02')
      ]
    )
  }
  let!(:legislation3) {
    create(
      :legislation,
      :published,
      :executive,
      laws_sectors: [sector3],
      title: 'Zimbabwe: National contingency plan 2012-2013',
      events: [
        build(:event, event_type: 'law_passed', date: '2016-12-02')
      ]
    )
  }
  let!(:legislation4) {
    create(
      :legislation,
      :published,
      :executive,
      laws_sectors: [sector2],
      title: 'Some natural law',
      responses: [adaptation],
      events: [
        build(:event, event_type: 'law_passed', date: '2010-12-02')
      ]
    )
  }

  # It shouldn't show, so total is 4 not 5 at max!
  let!(:unpublished_legislation) { create(:legislation, :legislative, :draft) }

  subject { described_class }

  describe 'call' do
    it 'should return all legislations with no filters' do
      results = subject.new({}).call

      expect(results.size).to eq(4)
      expect(results).not_to include(unpublished_legislation)
    end

    it 'should use full text search' do
      results = subject.new(q: 'protect').call
      expect(results.size).to eq(1)
      expect(results).to contain_exactly(legislation2)
    end

    it 'should filter by executive type' do
      results = subject.new(type: 'executive').call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(legislation1, legislation3, legislation4)
    end

    it 'should filter by legislative type' do
      results = subject.new(type: 'legislative').call
      expect(results.size).to eq(1)
      expect(results).to contain_exactly(legislation2)
    end

    it 'should filter by instrument' do
      # results = subject.new(instrument: []).call
    end

    it 'should filter by sector' do
      results = subject.new(law_sector: [sector1.id, sector2.id]).call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(legislation1, legislation2, legislation4)
    end

    it 'should filter by tags' do
      results = subject.new(keywords: [cap_and_trade.id, biodiversity.id], responses: [adaptation.id]).call
      expect(results).to contain_exactly(legislation1, legislation2, legislation4)
    end

    it 'should filter by from date' do
      results = subject.new(from_date: '2011').call
      expect(results).to contain_exactly(legislation1, legislation2, legislation3)
    end

    it 'should filter by to date' do
      results = subject.new(to_date: '2013').call
      expect(results).to contain_exactly(legislation1, legislation4)
    end

    it 'should filter by status' do
      results = subject.new(status: ['amended']).call
      expect(results).to contain_exactly(legislation1)
    end

    it 'should filter by multiple params' do
      results = subject.new(q: 'Nat', from_date: '2014').call
      expect(results).to contain_exactly(legislation3, legislation4)
    end

    it 'should be ordered by last event date' do
      results = subject.new({}).call
      expect(results.map(&:id)).to eq([legislation3.id, legislation2.id, legislation1.id, legislation4.id])
    end
  end
end
