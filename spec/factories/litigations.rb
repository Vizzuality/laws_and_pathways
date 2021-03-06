# == Schema Information
#
# Table name: litigations
#
#  id                        :bigint           not null, primary key
#  title                     :string           not null
#  slug                      :string           not null
#  citation_reference_number :string
#  document_type             :string
#  geography_id              :bigint
#  summary                   :text
#  at_issue                  :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  created_by_id             :bigint
#  updated_by_id             :bigint
#  discarded_at              :datetime
#  jurisdiction              :string
#  tsv                       :tsvector
#

FactoryBot.define do
  factory :litigation do
    draft

    geography { association :geography, created_by: created_by }
    jurisdiction { 'Court in Country' }
    # laws_sectors { |a| [a.association(:laws_sector)] }

    association :created_by, factory: :admin_user
    updated_by { created_by }

    sequence(:title) { |n| 'Litigation title -' + ('AAAA'..'ZZZZ').to_a[n] }
    document_type { 'administrative_case' }
    citation_reference_number { 'SFKD777FDK77' }
    summary { 'Summary Lorem ipsum dolor dalej nie pamietam' }
    at_issue { 'At issue Lorem ipsumumum' }

    trait :with_sides do
      after(:create) do |l|
        create :litigation_side, litigation: l, side_type: 'a'
        create :litigation_side, :company, litigation: l, side_type: 'a'
        create :litigation_side, :geography, litigation: l, side_type: 'b'
      end
    end

    trait :with_events do
      after(:create) do |l|
        create_list :litigation_event, 2, eventable: l
      end
    end
  end
end
