# == Schema Information
#
# Table name: litigation_sides
#
#  id                    :bigint           not null, primary key
#  litigation_id         :bigint
#  name                  :string
#  side_type             :string           not null
#  party_type            :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  connected_entity_type :string
#  connected_entity_id   :bigint
#

FactoryBot.define do
  factory :litigation_side do
    association :litigation

    sequence(:name) { |n| 'Litigation side name -' + ('AA'..'ZZ').to_a[n] }
    side_type { 'a' }
    party_type { 'individual' }

    trait :company do
      connected_entity { |d| d.association(:company) }
      party_type { 'corporation' }
    end

    trait :geography do
      connected_entity { |d| d.association(:geography) }
      party_type { 'government' }
    end
  end
end
