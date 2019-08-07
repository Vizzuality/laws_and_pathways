# == Schema Information
#
# Table name: litigations
#
#  id                        :bigint           not null, primary key
#  title                     :string           not null
#  slug                      :string           not null
#  citation_reference_number :string
#  document_type             :string
#  location_id               :bigint
#  jurisdiction_id           :bigint
#  summary                   :text
#  core_objective            :text
#  keywords                  :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#

FactoryBot.define do
  factory :litigation do
    association :location
    association :jurisdiction, factory: :location

    sequence(:title) { |n| 'Litigation title -' + ('AA'..'ZZ').to_a[n] }
    document_type { 'case' }
    citation_reference_number { 'SFKD777FDK77' }
    summary { 'Summary Lorem ipsum dolor dalej nie pamietam' }
    core_objective { 'Core objectives Lorem ipsumumum' }
    visibility_status { Litigation::VISIBILITY.sample }

    trait :with_sides do
      after(:create) do |l|
        create :litigation_side, litigation: l, side_type: 'a'
        create :litigation_side, :company, litigation: l, side_type: 'a'
        create :litigation_side, :location, litigation: l, side_type: 'b'
      end
    end
  end
end
