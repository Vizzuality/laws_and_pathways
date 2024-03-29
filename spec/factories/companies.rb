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
#  company_comments_internal :text
#  active                    :boolean          default(TRUE)
#

FactoryBot.define do
  factory :company do
    draft

    association :geography
    headquarters_geography { geography }
    association :sector, factory: :tpi_sector

    sequence(:name) { |n| 'Company name -' + ('AAAA'..'ZZZZ').to_a[n] }
    isin { SecureRandom.uuid }

    ca100 { true }
    active { true }
    market_cap_group { Company::MARKET_CAP_GROUPS.sample }

    latest_information { 'My information' }
    company_comments_internal { 'I changed my name last week' }

    trait :with_mq_assessments do
      after(:create) do |c|
        create :mq_assessment, company: c, assessment_date: 1.year.ago
        create :mq_assessment, company: c, assessment_date: 1.month.ago
      end
    end

    trait :with_cp_assessments do
      after(:create) do |c|
        create :cp_assessment, cp_assessmentable: c, assessment_date: 1.year.ago
        create :cp_assessment, cp_assessmentable: c, assessment_date: 1.month.ago
      end
    end
  end
end
