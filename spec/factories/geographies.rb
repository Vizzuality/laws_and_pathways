# == Schema Information
#
# Table name: geographies
#
#  id                       :bigint           not null, primary key
#  geography_type           :string           not null
#  iso                      :string           not null
#  name                     :string           not null
#  slug                     :string           not null
#  region                   :string           not null
#  federal                  :boolean          default(FALSE), not null
#  federal_details          :text
#  legislative_process      :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  visibility_status        :string           default("draft")
#  created_by_id            :bigint
#  updated_by_id            :bigint
#  discarded_at             :datetime
#  percent_global_emissions :string
#  climate_risk_index       :string
#  wb_income_group          :string
#

FactoryBot.define do
  factory :geography do
    draft

    sequence(:name) { |n| "name-#{('AAAA'..'ZZZZ').to_a[n]}" }
    sequence(:iso) { |n| ('AAA'..'ZZZ').to_a[n] }

    geography_type { 'national' }
    region { Geography::REGIONS.first }
    federal { false }
    percent_global_emissions { '10.0' }
    climate_risk_index { '0.5' }
    wb_income_group { 'Rich' }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user
  end
end
