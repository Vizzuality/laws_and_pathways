# == Schema Information
#
# Table name: news_articles
#
#  id               :bigint           not null, primary key
#  title            :string
#  content          :text
#  publication_date :datetime
#  created_by_id    :bigint
#  updated_by_id    :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryBot.define do
  factory :news_article do
    title { 'MyString' }
    content { 'MyText' }
    tpi_sectors { |a| [a.association(:tpi_sector)] }
    publication_date { '2019-11-29' }
    image { fixture_file_upload(Rails.root.join('spec', 'support', 'fixtures', 'files', 'test.jpg'), 'jpg') }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user

    trait :published do
      publication_date { 20.days.ago }
    end

    trait :not_published do
      publication_date { 12.days.from_now }
    end
  end
end
