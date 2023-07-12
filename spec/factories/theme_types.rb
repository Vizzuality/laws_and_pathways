# == Schema Information
#
# Table name: theme_types
#
#  id           :bigint           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

FactoryBot.define do
  factory :theme_type do
    sequence(:name) { |n| "theme_type#{n}" }

    trait :with_themes do
      after(:create) do
        create :theme
        create :theme
      end
    end
  end
end
