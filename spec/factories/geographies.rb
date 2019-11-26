# == Schema Information
#
# Table name: geographies
#
#  id                  :bigint           not null, primary key
#  geography_type      :string           not null
#  iso                 :string           not null
#  name                :string           not null
#  slug                :string           not null
#  region              :string           not null
#  federal             :boolean          default(FALSE), not null
#  federal_details     :text
#  legislative_process :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  visibility_status   :string           default("draft")
#  created_by_id       :bigint
#  updated_by_id       :bigint
#  discarded_at        :datetime
#

FactoryBot.define do
  factory :geography do
    sequence(:name) { |n| "name-#{('AA'..'ZZ').to_a[n]}" }
    sequence(:iso) { |n| ('AAA'..'ZZZ').to_a[n] }

    geography_type { 'national' }
    region { Geography::REGIONS.sample }
    visibility_status { Litigation::VISIBILITY.sample }
    federal { false }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user
  end
end
