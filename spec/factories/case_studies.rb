FactoryBot.define do
  factory :case_study do
    logo { TestFiles.png }
    text { 'I loved the site' }
    organization { 'Company' }
    link { 'https://example.com' }
  end
end
