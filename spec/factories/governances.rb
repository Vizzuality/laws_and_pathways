# == Schema Information
#
# Table name: governances
#
#  id                 :bigint           not null, primary key
#  name               :string
#  governance_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#

FactoryBot.define do
  factory :governance do
    sequence(:name) { |n| "governance#{n}" }
    association :governance_type
  end
end
