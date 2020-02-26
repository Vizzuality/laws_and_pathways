# == Schema Information
#
# Table name: laws_sectors
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  parent_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :laws_sector do
    sequence(:name) { |n| 'name-' + ('AAAA'..'ZZZZ').to_a[n] }
  end
end
