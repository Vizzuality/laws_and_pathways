# == Schema Information
#
# Table name: external_legislations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  url          :string
#  geography_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :external_legislation do
    name { 'Test External Legislation' }
    url { 'https://example.test.pl' }

    association :geography
  end
end
