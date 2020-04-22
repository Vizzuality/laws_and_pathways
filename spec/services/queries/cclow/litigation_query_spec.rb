require 'rails_helper'

RSpec.describe Queries::CCLOW::LitigationQuery do
  before(:all) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start

    @side_a1 = create(:litigation_side, name: 'Side A', side_type: 'a', party_type: 'corporation')
    @side_a11 = create(:litigation_side, name: 'Side A 2', side_type: 'a', party_type: 'corporation')
    @side_a12 = create(:litigation_side, name: 'Side A 3', side_type: 'a', party_type: 'government')
    @side_a2 = create(:litigation_side, name: 'Second Side A', side_type: 'a', party_type: 'government')
    @side_b1 = create(:litigation_side, name: 'Side B', side_type: 'b', party_type: 'corporation')
    @side_c1 = create(:litigation_side, name: 'Side C', side_type: 'c', party_type: 'individual')
    @side_c2 = create(:litigation_side, name: 'Side C', side_type: 'c', party_type: 'corporation')

    @biodiversity = create(:keyword, name: 'Biodiversity')
    @business_risk = create(:keyword, name: 'Business risk')
    @cap_and_trade = create(:keyword, name: 'Cap and Trade')
    @sector1 = create(:laws_sector)
    @sector2 = create(:laws_sector)
    @sector3 = create(:laws_sector)
    @geography1 = create(:geography, region: 'East Asia & Pacific')
    @geography2 = create(:geography, region: 'Europe & Central Asia')
    @geography3 = create(:geography, region: 'Europe & Central Asia')

    @litigation1 = create(
      :litigation,
      :published,
      geography: @geography1,
      jurisdiction: 'Federal court',
      laws_sectors: [@sector1, @sector3],
      title: 'PGE vs Common folks',
      litigation_sides: [@side_a1, @side_a11, @side_a12, @side_b1, @side_c1],
      keywords: [@biodiversity, @cap_and_trade],
      events: [
        build(:event, event_type: 'case_started', date: '2010-01-01'),
        build(:event, event_type: 'case_decided', date: '2013-03-01')
      ]
    )

    @litigation2 = create(
      :litigation,
      :published,
      geography: @geography2,
      jurisdiction: 'Argentina',
      laws_sectors: [@sector1],
      title: 'Testing',
      litigation_sides: [@side_a2],
      keywords: [@business_risk, @cap_and_trade],
      events: [
        build(:event, event_type: 'case_started', date: '2014-12-02')
      ]
    )

    @litigation3 = create(
      :litigation,
      :published,
      geography: @geography3,
      laws_sectors: [@sector3],
      litigation_sides: [@side_c2],
      events: [
        build(:event, event_type: 'case_started', date: '2016-12-02')
      ]
    )

    @litigation4 = create(
      :litigation,
      :published,
      geography: @geography1,
      laws_sectors: [@sector2]
    )

    @unpublished_litigation = create(:litigation, :draft)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  # It shouldn't show, so total is 4 not 5 at max!

  subject { described_class }

  describe 'call' do
    it 'should return all litigations with no filters' do
      results = subject.new({}).call

      expect(results.size).to eq(4)
      expect(results).not_to include(@unpublished_litigation)
    end

    it 'should use full text search' do
      results = subject.new(q: 'PGE').call
      expect(results.size).to eq(1)
      expect(results).to contain_exactly(@litigation1)
    end

    it 'should filter by tags' do
      results = subject.new(keywords: [@cap_and_trade.id, @biodiversity.id]).call
      expect(results).to contain_exactly(@litigation1, @litigation2)
    end

    it 'should filter by sector' do
      results = subject.new(law_sector: [@sector1.id, @sector2.id]).call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@litigation1, @litigation2, @litigation4)
    end

    it 'should filter by region' do
      results = subject.new(region: 'Europe & Central Asia').call
      expect(results.size).to eq(2)
      expect(results).to contain_exactly(@litigation2, @litigation3)
    end

    it 'should filter by geography' do
      results = subject.new(geography: [@geography1.id, @geography3.id]).call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@litigation1, @litigation3, @litigation4)
    end

    it 'should filter by region and geography' do
      results = subject.new(geography: [@geography2.id], region: 'East Asia & Pacific').call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@litigation1, @litigation2, @litigation4)
    end

    it 'should filter by jurisdiction' do
      results = subject.new(jurisdiction: 'Federal court').call
      expect(results.size).to eq(1)
      expect(results).to contain_exactly(@litigation1)
    end

    it 'should filter by date of last change from' do
      results = subject.new(last_change_from: '2011').call
      expect(results).to contain_exactly(@litigation1, @litigation2, @litigation3)
    end

    it 'should filter by date of last change to' do
      results = subject.new(last_change_to: '2013').call
      expect(results).to contain_exactly(@litigation1)
    end

    it 'should filter by single litigaton side a' do
      results = subject.new(side_a: ['Side A']).call
      expect(results).to contain_exactly(@litigation1)
    end

    it 'should filter by all side As litigaton side a' do
      results = subject.new(side_a: ['Side A', 'Second Side A']).call
      expect(results).to contain_exactly(@litigation1, @litigation2)
    end

    it 'should filter by side A and Side B by matching both sides' do
      results = subject.new(side_a: ['Side A'], side_b: ['Side B']).call
      expect(results).to contain_exactly(@litigation1)
    end

    it 'should filter by side A and Side B by matching both sides' do
      results = subject.new(side_a: ['Second Side A'], side_b: ['Side B']).call
      expect(results.size).to eq(0)
    end

    it 'should filter by side C' do
      results = subject.new(side_c: ['Side C']).call
      expect(results).to contain_exactly(@litigation1, @litigation3)
    end

    it 'should filter by side C, A and B' do
      results = subject.new(side_a: ['Side A'], side_b: ['Side B'], side_c: ['Side C']).call
      expect(results).to contain_exactly(@litigation1)
    end

    it 'should filter by party type' do
      results = subject.new(party_type: ['corporation']).call
      expect(results.size).to eq(2)
      expect(results).to contain_exactly(@litigation1, @litigation3)
    end

    it 'should filter by "a" party type' do
      results = subject.new(a_party_type: ['corporation']).call
      expect(results.size).to eq(1)
      expect(results).to contain_exactly(@litigation1)
    end

    it 'should filter by status' do
      results = subject.new(status: ['case_decided']).call
      expect(results).to contain_exactly(@litigation1)
    end

    it 'should filter by multiple params' do
      results = subject.new(q: 'testing', last_change_from: '2011', side_a: ['Second Side A']).call
      expect(results).to contain_exactly(@litigation2)
    end

    it 'should be ordered by last event date' do
      results = subject.new({}).call
      expect(results.map(&:id)).to eq([@litigation3.id, @litigation2.id, @litigation1.id, @litigation4.id])
    end
  end
end
