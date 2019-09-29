# == Schema Information
#
# Table name: instruments
#
#  id                 :bigint           not null, primary key
#  name               :string
#  instrument_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#

FactoryBot.define do
  factory :instrument do
    sequence(:name) { |n| "instrument#{n}" }
    association :instrument_type
  end
end
