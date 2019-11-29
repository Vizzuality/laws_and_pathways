FactoryBot.define do
  factory :news_article do
    title { "MyString" }
    content { "MyText" }
    publication_date { "2019-11-29" }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user
  end
end
