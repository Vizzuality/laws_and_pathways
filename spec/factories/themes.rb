# == Schema Information
#
# Table name: themes
#
#  id                 :bigint           not null, primary key
#  name               :string
#  theme_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#

FactoryBot.define do
  factory :theme do
    sequence(:name) { |n| "theme#{n}" }
    association :theme_type
  end
end
