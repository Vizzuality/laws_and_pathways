FactoryBot.define do
  factory :news_article do
    title { "MyString" }
    content { "MyText" }
    publication_date { "2019-11-29" }
    created_by { nil }
    updated_by { nil }
  end
end
