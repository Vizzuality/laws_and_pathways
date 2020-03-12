# == Schema Information
#
# Table name: legislations
#
#  id                :bigint           not null, primary key
#  title             :string
#  description       :text
#  law_id            :integer
#  slug              :string           not null
#  geography_id      :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  visibility_status :string           default("draft")
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  discarded_at      :datetime
#  legislation_type  :string           not null
#  parent_id         :bigint
#

FactoryBot.define do
  factory :legislation do
    draft

    sequence(:title) { |n| "Legislation #{n} Title" }
    description { 'Test Legislation Description' }
    sequence(:law_id)
    legislation_type { 'executive' }
    discarded_at { nil }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user

    association :geography
    laws_sectors { |a| [a.association(:laws_sector)] }

    trait :executive do
      legislation_type { 'executive' }
    end

    trait :legislative do
      legislation_type { 'legislative' }
    end
  end
end
