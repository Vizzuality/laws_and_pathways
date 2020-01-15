require 'rails_helper'

RSpec.describe Queries::CCLOW::LitigationQuery do
  let(:side_a1) { create(:litigation_side, name: 'Side A', side_type: 'a') }
  let(:side_a2) { create(:litigation_side, name: 'Second Side A', side_type: 'a') }
  let(:side_b1) { create(:litigation_side, name: 'Side B', side_type: 'b') }
  let(:side_c1) { create(:litigation_side, name: 'Side C', side_type: 'c') }
  let(:side_c2) { create(:litigation_side, name: 'Side C', side_type: 'c') }

  let!(:litigation1) {
    litigation = create(:published_litigation)
    litigation.litigation_sides << side_a1
    litigation.litigation_sides << side_b1
    litigation.litigation_sides << side_c1
    litigation
  }
  let!(:litigation2) {
    litigation = create(:published_litigation)
    litigation.litigation_sides << side_a2
    litigation
  }
  let!(:litigation3) {
    litigation = create(:published_litigation)
    litigation.litigation_sides << side_c2
    litigation
  }
  let!(:litigation4) { create(:published_litigation) }

  # It shouldn't show, so total is 4 not 5 at max!
  let!(:unpublished_litigation) { create(:litigation, visibility_status: 'draft') }

  subject { described_class }

  describe 'call' do
    it 'should return all litigations with no filters' do
      results = subject.new({}).call

      expect(results.count).to eq(4)
    end

    it 'should filter by single litigaton side a' do
      results = subject.new(side_a: ['Side A']).call
      expect(results.count).to eq(1)
    end

    it 'should filter by all side As litigaton side a' do
      results = subject.new(side_a: ['Side A', 'Second Side A']).call
      expect(results.count).to eq(2)
    end

    it 'should filter by side A and Side B by matching both sides' do
      results = subject.new(side_a: ['Side A'], side_b: ['Side B']).call
      expect(results.count).to eq(1)
    end

    it 'should filter by side A and Side B by matching both sides' do
      results = subject.new(side_a: ['Second Side A'], side_b: ['Side B']).call
      expect(results.count).to eq(0)
    end

    it 'should filter by side C' do
      results = subject.new(side_c: ['Side C']).call
      expect(results.count).to eq(2)
    end

    it 'should filter by side C, A and B' do
      results = subject.new(side_a: ['Side A'], side_b: ['Side B'], side_c: ['Side C']).call
      expect(results.count).to eq(1)
    end
  end
end
