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
#  date_passed       :date
#  visibility_status :string           default("draft")
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  discarded_at      :datetime
#  legislation_type  :string           not null
#  sector_id         :bigint
#

FactoryBot.define do
  factory :legislation do
    sequence(:title) { |n| "Legislation #{n} Title" }
    description { 'Test Legislation Description' }
    date_passed { 2.years.ago }
    sequence(:law_id)
    visibility_status { Legislation::VISIBILITY.first }
    legislation_type { 'executive' }
    discarded_at { nil }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user

    association :geography
    association :sector, factory: :laws_sector
  end
end
