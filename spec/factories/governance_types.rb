# == Schema Information
#
# Table name: governance_types
#
#  id           :bigint           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

FactoryBot.define do
  factory :governance_type do
    sequence(:name) { |n| "governance_type#{n}" }

    trait :with_governances do
      after(:create) do
        create :governance
        create :governance
      end
    end
  end
end
