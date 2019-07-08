FactoryBot.define do
  factory :sector do
    sequence(:name) { |n| 'name-' + ('AA'..'ZZ').to_a[n] }

    trait :with_benchmarks do
      after(:create) do |s|
        create :cp_benchmark, sector: s, date: 1.year.ago
        create :cp_benchmark, sector: s, date: 1.month.ago
      end
    end
  end
end
