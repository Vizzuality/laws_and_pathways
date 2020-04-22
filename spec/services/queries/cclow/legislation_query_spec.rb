require 'rails_helper'

RSpec.describe Queries::CCLOW::LegislationQuery do
  before(:all) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start

    @biodiversity = create(:keyword, name: 'Biodiversity')
    @business_risk = create(:keyword, name: 'Business risk')
    @cap_and_trade = create(:keyword, name: 'Cap and Trade')
    @adaptation = create(:response, name: 'Adaptation')
    @mitigation = create(:response, name: 'Mitigation')
    @sector1 = create(:laws_sector)
    @sector2 = create(:laws_sector)
    @sector3 = create(:laws_sector)
    @instrument1 = create(:instrument)
    @instrument2 = create(:instrument)
    @instrument3 = create(:instrument)
    @geography1 = create(:geography, region: 'East Asia & Pacific')
    @geography2 = create(:geography, region: 'Europe & Central Asia')
    @geography3 = create(:geography, region: 'Europe & Central Asia')

    @legislation1 = create(
      :legislation,
      :published,
      :executive,
      geography: @geography1,
      laws_sectors: [@sector1, @sector3],
      title: 'Union Budget 2019-2020',
      keywords: [@biodiversity, @cap_and_trade],
      responses: [@adaptation],
      instruments: [@instrument1, @instrument3],
      events: [
        build(:event, event_type: 'law_passed', date: '2010-01-01'),
        build(:event, event_type: 'amended', date: '2013-03-01')
      ]
    )

    @legislation2 = create(
      :legislation,
      :published,
      :legislative,
      geography: @geography2,
      laws_sectors: [@sector1],
      instruments: [@instrument1],
      title: 'Act No. 7 of 1994 on protection against natural damage',
      keywords: [@business_risk, @cap_and_trade],
      events: [
        build(:event, event_type: 'law_passed', date: '2014-12-02')
      ]
    )

    @legislation3 = create(
      :legislation,
      :published,
      :executive,
      geography: @geography3,
      instruments: [@instrument3],
      laws_sectors: [@sector3],
      title: 'Zimbabwe: National contingency plan 2012-2013',
      events: [
        build(:event, event_type: 'law_passed', date: '2016-12-02')
      ]
    )

    @legislation4 = create(
      :legislation,
      :published,
      :executive,
      geography: @geography1,
      laws_sectors: [@sector2],
      title: 'Some natural law',
      responses: [@adaptation],
      events: [
        build(:event, event_type: 'law_passed', date: '2010-12-02')
      ]
    )

    # It shouldn't show, so total is 4 not 5 at max!
    @unpublished_legislation = create(:legislation, :legislative, :draft)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  subject { described_class }

  describe 'call' do
    it 'should return all legislations with no filters' do
      results = subject.new({}).call

      expect(results.size).to eq(4)
      expect(results).not_to include(@unpublished_legislation)
    end

    it 'should use full text search' do
      results = subject.new(q: 'protect').call
      expect(results.size).to eq(1)
      expect(results).to contain_exactly(@legislation2)
    end

    it 'should filter by executive type' do
      results = subject.new(type: 'executive').call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@legislation1, @legislation3, @legislation4)
    end

    it 'should filter by legislative type' do
      results = subject.new(type: 'legislative').call
      expect(results.size).to eq(1)
      expect(results).to contain_exactly(@legislation2)
    end

    it 'should filter by instrument' do
      results = subject.new(instrument: [@instrument3.id]).call
      expect(results.size).to eq(2)
      expect(results).to contain_exactly(@legislation1, @legislation3)
    end

    it 'should filter by region' do
      results = subject.new(region: 'Europe & Central Asia').call
      expect(results.size).to eq(2)
      expect(results).to contain_exactly(@legislation2, @legislation3)
    end

    it 'should filter by geography' do
      results = subject.new(geography: [@geography1.id, @geography3.id]).call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@legislation1, @legislation3, @legislation4)
    end

    it 'should filter by region and geography' do
      results = subject.new(geography: [@geography2.id], region: 'East Asia & Pacific').call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@legislation1, @legislation2, @legislation4)
    end

    it 'should filter by sector' do
      results = subject.new(law_sector: [@sector1.id, @sector2.id]).call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@legislation1, @legislation2, @legislation4)
    end

    it 'should filter by tags' do
      results = subject.new(keywords: [@cap_and_trade.id, @biodiversity.id], responses: [@adaptation.id]).call
      expect(results).to contain_exactly(@legislation1, @legislation2, @legislation4)
    end

    it 'should filter by date of last change from' do
      results = subject.new(last_change_from: '2011').call
      expect(results).to contain_exactly(@legislation1, @legislation2, @legislation3)
    end

    it 'should filter by to date' do
      results = subject.new(last_change_to: '2013').call
      expect(results).to contain_exactly(@legislation1, @legislation4)
    end

    it 'should filter by multiple params' do
      results = subject.new(q: 'Nat', last_change_from: '2014', instrument: [@instrument3.id]).call
      expect(results).to contain_exactly(@legislation3)
    end

    it 'should be ordered by last event date' do
      results = subject.new({}).call
      expect(results.map(&:id)).to eq([@legislation3.id, @legislation2.id, @legislation1.id, @legislation4.id])
    end
  end
end
