# == Schema Information
#
# Table name: tpi_sectors
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  slug             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cluster_id       :bigint
#  show_in_tpi_tool :boolean          default(TRUE), not null
#

FactoryBot.define do
  factory :tpi_sector do
    sequence(:name) { |n| 'name-' + ('AAAA'..'ZZZZ').to_a[n] }

    trait :with_benchmarks do
      after(:create) do |s|
        create :cp_benchmark, sector: s, release_date: 1.year.ago
        create :cp_benchmark, sector: s, release_date: 1.month.ago
      end
    end
  end
end
