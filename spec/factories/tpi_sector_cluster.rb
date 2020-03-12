FactoryBot.define do
  factory :tpi_sector_cluster do
    sequence(:name) { |n| 'name-' + ('AA'..'ZZ').to_a[n] }
  end
end
