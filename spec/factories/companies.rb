# == Schema Information
#
# Table name: companies
#
#  id                        :bigint           not null, primary key
#  geography_id              :bigint
#  headquarters_geography_id :bigint
#  sector_id                 :bigint
#  name                      :string           not null
#  slug                      :string           not null
#  isin                      :string           not null
#  market_cap_group          :string
#  ca100                     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  discarded_at              :datetime
#  sedol                     :string
#  latest_information        :text
#  historical_comments       :text
#

FactoryBot.define do
  factory :company do
    association :geography
    association :headquarters_geography, factory: :geography
    association :sector, factory: :tpi_sector

    sequence(:name) { |n| 'Company name -' + ('AA'..'ZZ').to_a[n] }
    isin { SecureRandom.uuid }

    ca100 { true }
    market_cap_group { Company::MARKET_CAP_GROUPS.sample }
    visibility_status { Litigation::VISIBILITY.sample }

    latest_information { 'My information' }
    historical_comments { 'I changed my name last week' }

    trait :with_mq_assessments do
      after(:create) do |c|
        create :mq_assessment, company: c, assessment_date: 1.year.ago
        create :mq_assessment, company: c, assessment_date: 1.month.ago
      end
    end

    trait :with_cp_assessments do
      after(:create) do |c|
        create :cp_assessment, company: c, assessment_date: 1.year.ago
        create :cp_assessment, company: c, assessment_date: 1.month.ago
      end
    end
  end
end
