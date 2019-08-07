# == Schema Information
#
# Table name: targets
#
#  id                :bigint           not null, primary key
#  location_id       :bigint
#  sector_id         :bigint
#  target_scope_id   :bigint
#  ghg_target        :boolean          default(FALSE), not null
#  single_year       :boolean          default(FALSE), not null
#  description       :text
#  year              :integer
#  base_year_period  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  target_type       :string
#  visibility_status :string           default("draft")
#

FactoryBot.define do
  factory :target do
    association :location
    association :sector
    association :target_scope

    description { 'Target description' }
    year { 2023 }
    ghg_target { false }
    single_year { true }
    target_type { 'base_year_target' }
    visibility_status { Litigation::VISIBILITY.sample }
  end
end
