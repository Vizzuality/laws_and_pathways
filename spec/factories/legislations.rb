# == Schema Information
#
# Table name: legislations
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  law_id      :integer
#  framework   :string
#  slug        :string           not null
#  location_id :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :legislation do
    title { 'Test Legislation' }
    description { 'Test Legislation Description' }
    law_id { 1 }
    framework { Legislation::FRAMEWORKS.sample }
    location
  end
end
