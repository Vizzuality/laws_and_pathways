# == Schema Information
#
# Table name: news_articles
#
#  id                :bigint           not null, primary key
#  title             :string
#  content           :text
#  publication_date  :datetime
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_insight        :boolean          default(FALSE)
#  short_description :text
#  is_event          :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe NewsArticle, type: :model do
  subject { build(:news_article) }

  it { is_expected.to be_valid }

  it 'should be invalid without title' do
    subject.title = nil
    expect(subject).to have(1).errors_on(:title)
  end

  it 'should be invalid without content' do
    subject.content = nil
    expect(subject).to have(1).errors_on(:content)
  end

  it 'should be invalid without publication date' do
    subject.publication_date = nil
    expect(subject).to have(1).errors_on(:publication_date)
  end
end
