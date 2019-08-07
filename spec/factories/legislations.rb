# == Schema Information
#
# Table name: legislations
#
#  id                :bigint           not null, primary key
#  title             :string
#  description       :text
#  law_id            :integer
#  framework         :string
#  slug              :string           not null
#  location_id       :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  date_passed       :date
#  visibility_status :string           default("draft")
#

FactoryBot.define do
  factory :legislation do
    sequence(:title) { |n| "Legislation #{n} Title" }
    description { 'Test Legislation Description' }
    date_passed { 2.years.ago }
    sequence(:law_id)
    framework { Legislation::FRAMEWORKS.sample }
    visibility_status { Legislation::VISIBILITY.sample }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user

    association :location
  end
end
