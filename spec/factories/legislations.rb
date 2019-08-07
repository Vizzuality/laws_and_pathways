# == Schema Information
#
# Table name: legislations
#
#  id                :bigint           not null, primary key
#  title             :string
#  description       :text
#  law_id            :integer
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
    visibility_status { Legislation::VISIBILITY.sample }

    association :location
  end
end
