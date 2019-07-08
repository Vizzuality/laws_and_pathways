# == Schema Information
#
# Table name: companies
#
#  id                      :bigint(8)        not null, primary key
#  location_id             :bigint(8)
#  headquarter_location_id :bigint(8)
#  sector_id               :bigint(8)
#  name                    :string           not null
#  slug                    :string           not null
#  isin                    :string           not null
#  size                    :string
#  ca100                   :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

FactoryBot.define do
  factory :company do
    association :location
    association :headquarter_location, factory: :location
    association :sector

    sequence(:name) { |n| 'Company name -' + ('AA'..'ZZ').to_a[n] }
    isin { SecureRandom.uuid }

    ca100 { true }
    size { Company::SIZES.sample }

    trait :with_mq_assessments do
      after(:create) do |s|
        create :mq_assessment, sector: s, date: 1.year.ago
        create :mq_assessment, sector: s, date: 1.month.ago
      end
    end
  end
end
