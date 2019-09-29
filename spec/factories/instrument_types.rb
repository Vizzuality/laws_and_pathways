# == Schema Information
#
# Table name: instrument_types
#
#  id           :bigint           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

FactoryBot.define do
  factory :instrument_type do
    sequence(:name) { |n| "instrument_type#{n}" }

    trait :with_instruments do
      after(:create) do
        create :instrument
        create :instrument
      end
    end
  end
end
