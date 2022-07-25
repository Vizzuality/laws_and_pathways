# == Schema Information
#
# Table name: banks
#
#  id                 :bigint           not null, primary key
#  geography_id       :bigint
#  name               :string           not null
#  slug               :string           not null
#  isin               :string           not null
#  sedol              :string
#  market_cap_group   :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  latest_information :text
#
FactoryBot.define do
  factory :bank do
    association :geography

    sequence(:name) { |n| 'Bank name -' + ('AAAA'..'ZZZZ').to_a[n] }
    isin { '342343433' }

    market_cap_group { 'large' }

    trait :with_assessments do
      after(:create) do |b|
        create :bank_assessment, bank: b, assessment_date: 1.year.ago
        create :bank_assessment, bank: b, assessment_date: 1.month.ago
      end
    end
  end
end
