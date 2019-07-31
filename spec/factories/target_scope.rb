FactoryBot.define do
  factory :target_scope do
    sequence(:name) { |n| "target_scope#{n}" }
  end
end
