require 'rails_helper'

RSpec.describe Queries::CCLOW::LitigationQuery do
  let(:side_a1) { create(:litigation_side, name: 'Side A', side_type: 'a') }
  let(:side_a2) { create(:litigation_side, name: 'Second Side A', side_type: 'a') }
  let(:side_b1) { create(:litigation_side, name: 'Side B', side_type: 'b') }
  let(:side_c1) { create(:litigation_side, name: 'Side C', side_type: 'c') }
  let(:side_c2) { create(:litigation_side, name: 'Side C', side_type: 'c') }

  let!(:litigation1) {
    litigation = create(
      :litigation,
      :published,
      title: 'PGE vs Common folks',
      litigation_sides: [side_a1, side_b1, side_c1],
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
      events: [
        build(:event, event_type: 'case_started', date: '2014-12-02')
      ]
    )
  }
  let!(:litigation3) { create(:litigation, :published, litigation_sides: [side_c2]) }
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

    it 'should filter by from date' do
      results = subject.new(from_date: '2011').call
      expect(results).to contain_exactly(litigation1, litigation2)
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

    it 'should filter by multiple params' do
      results = subject.new(q: 'Test', from_date: '2011', side_a: ['Side A']).call
      expect(results).to contain_exactly(litigation2)
    end
  end
end
