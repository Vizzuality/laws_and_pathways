# == Schema Information
#
# Table name: instrument_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :instrument_type do
    sequence(:name) { |n| "instrument_type#{n}" }
  end
end
