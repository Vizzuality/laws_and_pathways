require 'rails_helper'

RSpec.describe Queries::TPI::NewsPublicationsQuery do
  before_all do
    keyword1 = create(:keyword, name: 'keyword1')
    keyword2 = create(:keyword, name: 'keyword2')

    sector1 = create(:tpi_sector, name: 'sector1')
    sector2 = create(:tpi_sector, name: 'sector2')

    @news1 = create(
      :news_article,
      :published,
      keywords: [
        keyword1,
        keyword2
      ]
    )
    @news2 = create(
      :news_article,
      :published,
      keywords: [
        keyword1
      ]
    )
    @news3 = create(
      :news_article,
      keywords: [
        keyword1,
        keyword2
      ],
      publication_date: 3.days.from_now
    )

    @pub1 = create(:publication, :published, tpi_sectors: [sector1], keywords: [keyword1])
    @pub2 = create(:publication, :published, tpi_sectors: [sector2])
    @pub3 = create(:publication, tpi_sectors: [sector1], keywords: [keyword1], publication_date: 3.days.from_now)
  end

  subject { described_class }

  describe 'call' do
    it 'should return all news and publications with no filters' do
      results = subject.new.call
      expect(results.count).to eq(4)
    end

    it 'should filter by tags' do
      results = subject.new(tags: 'keyword1').call
      expect(results.count).to eq(3)
    end

    it 'should filter by multiple tags' do
      results = subject.new(tags: 'keyword1,keyword2').call
      expect(results.count).to eq(3)
      expect(results.map(&:id)).to contain_exactly(@news1.id, @news2.id, @pub1.id)
    end

    it 'should filter by sectors' do
      results = subject.new(sectors: 'sector1').call
      expect(results.count).to eq(1)
    end

    it 'should filter by tags and sectors' do
      results = subject.new(tags: 'keyword1', sectors: 'sector1').call
      expect(results.count).to eq(1)
    end
  end
end
