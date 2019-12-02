# == Schema Information
#
# Table name: news_articles
#
#  id               :bigint           not null, primary key
#  title            :string
#  content          :text
#  publication_date :date
#  created_by_id    :bigint
#  updated_by_id    :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  article_type     :string
#

FactoryBot.define do
  factory :news_article do
    title { 'MyString' }
    content { 'MyText' }
    publication_date { '2019-11-29' }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user
  end
end