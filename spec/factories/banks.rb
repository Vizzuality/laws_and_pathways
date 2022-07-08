FactoryBot.define do
  factory :bank do
    association :geography

    sequence(:name) { |n| 'Bank name -' + ('AAAA'..'ZZZZ').to_a[n] }
    isin { SecureRandom.uuid }

    market_cap_group { Bank::MARKET_CAP_GROUPS.sample }

    trait :with_assessments do
      after(:create) do |b|
        create :bank_assessment, bank: b, assessment_date: 1.year.ago
        create :bank_assessment, bank: b, assessment_date: 1.month.ago
      end
    end
  end
end