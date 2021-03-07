require 'rails_helper'

RSpec.describe Queries::CCLOW::TargetQuery do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start

    @geography1 = create(:geography, region: 'East Asia & Pacific')
    @geography2 = create(:geography, region: 'Europe & Central Asia')
    @geography3 = create(:geography, region: 'Europe & Central Asia')

    @target1 = create(
      :target,
      :published,
      geography: @geography1,
      target_type: 'base_year_target',
      description: 'Assure the development of climate resilience by reducing at least by 50% the climate change',
      events: [
        build(:event, event_type: 'set', date: '2010-01-01'),
        build(:event, event_type: 'updated', date: '2013-03-01')
      ]
    )

    @target2 = create(
      :target,
      :published,
      geography: @geography2,
      target_type: 'base_year_target',
      description: 'By 2020, the NAP process is completed by 2020',
      events: [
        build(:event, event_type: 'set', date: '2014-12-02')
      ]
    )

    @target3 = create(
      :target,
      :published,
      geography: @geography3,
      target_type: 'intensity_target',
      description: 'To have, by 2020, six regional risk-management plans (covering the entire country)',
      events: [
        build(:event, event_type: 'set', date: '2016-12-02')
      ]
    )

    @target4 = create(
      :target,
      :published,
      geography: @geography1,
      target_type: 'trajectory_target',
      description: 'Some climate target',
      events: [
        build(:event, event_type: 'set', date: '2010-12-02')
      ]
    )

    # It shouldn't show, so total is 4 not 5 at max!
    @unpublished_target = create(:target, :draft)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  subject { described_class }

  describe 'call' do
    it 'should return all targets with no filters' do
      results = subject.new({}).call

      expect(results.size).to eq(4)
      expect(results).not_to include(@unpublished_target)
    end

    it 'should use full text search' do
      results = subject.new(q: 'climate').call
      expect(results.size).to eq(2)
      expect(results).to contain_exactly(@target1, @target4)
    end

    it 'should filter by type' do
      results = subject.new(type: %w(intensity_target trajectory_target)).call
      expect(results.size).to eq(2)
      expect(results).to contain_exactly(@target3, @target4)
    end

    it 'should filter by multiple params' do
      results = subject.new(q: 'risk', last_change_from: '2014').call
      expect(results).to contain_exactly(@target3)
    end

    it 'should be ordered by last event date' do
      results = subject.new({}).call
      expect(results.map(&:id)).to eq([@target3.id, @target2.id, @target1.id, @target4.id])
    end

    it 'should filter by region' do
      results = subject.new(region: 'Europe & Central Asia').call
      expect(results.size).to eq(2)
      expect(results).to contain_exactly(@target2, @target3)
    end

    it 'should filter by geography' do
      results = subject.new(geography: [@geography1.id, @geography3.id]).call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@target1, @target3, @target4)
    end

    it 'should filter by region and geography' do
      results = subject.new(geography: [@geography2.id], region: 'East Asia & Pacific').call
      expect(results.size).to eq(3)
      expect(results).to contain_exactly(@target1, @target2, @target4)
    end
  end
end
