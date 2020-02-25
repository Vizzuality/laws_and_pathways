require 'rails_helper'

RSpec.describe Queries::CCLOW::LitigationQuery do
  let(:side_a1) { create(:litigation_side, name: 'Side A', side_type: 'a', party_type: 'corporation') }
  let(:side_a11) { create(:litigation_side, name: 'Side A 2', side_type: 'a', party_type: 'corporation') }
  let(:side_a12) { create(:litigation_side, name: 'Side A 3', side_type: 'a', party_type: 'government') }
  let(:side_a2) { create(:litigation_side, name: 'Second Side A', side_type: 'a', party_type: 'government') }
  let(:side_b1) { create(:litigation_side, name: 'Side B', side_type: 'b', party_type: 'corporation') }
  let(:side_c1) { create(:litigation_side, name: 'Side C', side_type: 'c', party_type: 'individual') }
  let(:side_c2) { create(:litigation_side, name: 'Side C', side_type: 'c', party_type: 'corporation') }

  let(:biodiversity) { create(:keyword, name: 'Biodiversity') }
  let(:business_risk) { create(:keyword, name: 'Business risk') }
  let(:cap_and_trade) { create(:keyword, name: 'Cap and Trade') }

  let!(:litigation1) {
    litigation = create(
      :litigation,
      :published,
      title: 'PGE vs Common folks',
      litigation_sides: [side_a1, side_a11, side_a12, side_b1, side_c1],
      keywords: [biodiversity, cap_and_trade],
      events: [
        build(:event, event_type: 'case_started', date: '2010-01-01'),
        build(:event, event_type: 'case_decided', date: '2013-03-01')
      ]
    )
    litigation
  }
  let!(:litigation2) {
    create(
      :litigation,
      :published,
      title: 'Testing',
      litigation_sides: [side_a2],
      keywords: [business_risk, cap_and_trade],
      events: [
        build(:event, event_type: 'case_started', date: '2014-12-02')
      ]
    )
  }
  let!(:litigation3) {
    create(
      :litigation,
      :published,
      litigation_sides: [side_c2],
      events: [
        build(:event, event_type: 'case_started', date: '2016-12-02')
      ]
    )
  }
  let!(:litigation4) { create(:litigation, :published) }

  # It shouldn't show, so total is 4 not 5 at max!
  let!(:unpublished_litigation) { create(:litigation, :draft) }

  subject { described_class }

  describe 'call' do
    it 'should return all litigations with no filters' do
      results = subject.new({}).call

      expect(results.count).to eq(4)
      expect(results).not_to include(unpublished_litigation)
    end

    it 'should use full text search' do
      results = subject.new(q: 'PGE').call
      expect(results).to contain_exactly(litigation1)
    end

    it 'should filter by tags' do
      results = subject.new(keywords: [cap_and_trade.id, biodiversity.id]).call
      expect(results).to contain_exactly(litigation1, litigation2)
    end

    it 'should filter by from date' do
      results = subject.new(from_date: '2011').call
      expect(results).to contain_exactly(litigation1, litigation2, litigation3)
    end

    it 'should filter by to date' do
      results = subject.new(to_date: '2013').call
      expect(results).to contain_exactly(litigation1)
    end

    it 'should filter by single litigaton side a' do
      results = subject.new(side_a: ['Side A']).call
      expect(results).to contain_exactly(litigation1)
    end

    it 'should filter by all side As litigaton side a' do
      results = subject.new(side_a: ['Side A', 'Second Side A']).call
      expect(results).to contain_exactly(litigation1, litigation2)
    end

    it 'should filter by side A and Side B by matching both sides' do
      results = subject.new(side_a: ['Side A'], side_b: ['Side B']).call
      expect(results).to contain_exactly(litigation1)
    end

    it 'should filter by side A and Side B by matching both sides' do
      results = subject.new(side_a: ['Second Side A'], side_b: ['Side B']).call
      expect(results.count).to eq(0)
    end

    it 'should filter by side C' do
      results = subject.new(side_c: ['Side C']).call
      expect(results).to contain_exactly(litigation1, litigation3)
    end

    it 'should filter by side C, A and B' do
      results = subject.new(side_a: ['Side A'], side_b: ['Side B'], side_c: ['Side C']).call
      expect(results).to contain_exactly(litigation1)
    end

    it 'should filter by party type' do
      results = subject.new(party_type: ['corporation']).call
      expect(results.count).to eq(2)
      expect(results).to contain_exactly(litigation1, litigation3)
    end

    it 'should filter by "a" party type' do
      results = subject.new(a_party_type: ['corporation']).call
      expect(results.count).to eq(1)
      expect(results).to contain_exactly(litigation1)
    end

    it 'should filter by status' do
      results = subject.new(status: ['case_decided']).call
      expect(results).to contain_exactly(litigation1)
    end

    it 'should filter by multiple params' do
      results = subject.new(q: 'Test', from_date: '2011', side_a: ['Side A']).call
      expect(results).to contain_exactly(litigation2)
    end

    it 'should be ordered by last event date' do
      results = subject.new({}).call
      expect(results.map(&:id)).to eq([litigation3.id, litigation2.id, litigation1.id, litigation4.id])
    end
  end
end
