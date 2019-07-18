FactoryBot.define do
  factory :legislation do
    title { 'Test Legislation' }
    description { 'Test Legislation Description' }
    law_id { 1 }
    framework { Legislation::FRAMEWORKS.sample }
    location
  end
end
