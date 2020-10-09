require 'rails_helper'

RSpec.describe Queries::TPI::NewsPublicationsQuery do
  let_it_be(:keyword_1) { create(:keyword, name: 'keyword1') }
  let_it_be(:keyword_2) { create(:keyword, name: 'keyword2') }
  let_it_be(:sector_1) { create(:tpi_sector, name: 'sector1') }
  let_it_be(:sector_2) { create(:tpi_sector, name: 'sector2') }

  let_it_be(:news_1) {
    create(
      :news_article,
      :published,
      keywords: [
        keyword_1,
        keyword_2
      ]
    )
  }
  let_it_be(:news_2) {
    create(
      :news_article,
      :published,
      keywords: [
        keyword_1
      ]
    )
  }
  let_it_be(:news_3) {
    create(
      :news_article,
      keywords: [
        keyword_1,
        keyword_2
      ],
      publication_date: 3.days.from_now
    )
  }
  let_it_be(:publication_1) { create(:publication, :published, tpi_sectors: [sector_1], keywords: [keyword_1]) }
  let_it_be(:publication_2) { create(:publication, :published, tpi_sectors: [sector_2]) }
  let_it_be(:publication_3) {
    create(:publication, tpi_sectors: [sector_1], keywords: [keyword_1], publication_date: 3.days.from_now)
  }

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
