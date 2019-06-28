FactoryBot.define do
  factory :sector do
    sequence(:name) { |n| 'name-' + ('AA'..'ZZ').to_a[n] }
  end
end
