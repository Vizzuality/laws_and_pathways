require 'rails_helper'

RSpec.describe Taggable do
  describe 'Legislation keywords' do
    let(:legislation) { create(:legislation) }

    describe 'keywords_list' do
      it 'should set keywords list properly' do
        keywords = %w(sport holiday travel)

        expect {
          legislation.keywords_list = keywords
        }.to change(Keyword, :count).by(3)

        expect(legislation.keywords.pluck(:name)).to include(*keywords)
      end

      it 'should not set keywords duplicates' do
        keywords = %w(sport sport sport holiday travel)

        expect {
          legislation.keywords_list = keywords
        }.to change(Keyword, :count).by(3)

        expect(legislation.keywords.size).to be(3)
        expect(legislation.keywords.pluck(:name)).to include(*keywords.uniq)
      end

      it 'should get keywords list' do
        legislation.keywords = [
          create(:keyword, name: 'sport'),
          create(:keyword, name: 'holiday'),
          create(:keyword, name: 'travel')
        ]

        expect(legislation.keywords_list.sort).to eq(%w(holiday sport travel))
      end
    end

    describe 'keywords_string' do
      it 'should set keywords list using string properly' do
        keywords = 'sport, holiday, travel'

        expect {
          legislation.keywords_string = keywords
        }.to change(Keyword, :count).by(3)

        expect(legislation.keywords.pluck(:name)).to include(*keywords.split(', '))
      end

      it 'should get keywords list in one string' do
        legislation.keywords = [
          create(:keyword, name: 'sport'),
          create(:keyword, name: 'holiday'),
          create(:keyword, name: 'travel')
        ]

        expect(legislation.keywords_string).to eq('sport, holiday, travel')
      end
    end

    describe 'keyword_ids' do
      let(:keyword1) { create(:keyword, name: 'sport') }
      let(:keyword2) { create(:keyword, name: 'holiday') }

      it 'should set keywords list using ids properly' do
        legislation.keyword_ids = [keyword1.id, keyword2.id]
        expect(legislation.keywords.pluck(:name)).to include(keyword1.name, keyword2.name)
        expect(legislation.keywords.count).to be(2)
      end

      it 'should not set keywords duplicates' do
        legislation.keyword_ids = [keyword1.id, keyword1.id, keyword1.id, keyword2.id, keyword2.id]
        expect(legislation.keywords.pluck(:name)).to include(keyword1.name, keyword2.name)
        expect(legislation.keywords.count).to be(2)
      end
    end
  end
end
