# == Schema Information
#
# Table name: targets
#
#  id                :bigint           not null, primary key
#  geography_id      :bigint
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
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  discarded_at      :datetime
#

FactoryBot.define do
  factory :target do
    association :geography
    association :sector
    association :target_scope
    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user

    description { 'Target description' }
    year { 2023 }
    ghg_target { false }
    single_year { true }
    target_type { 'base_year_target' }
    visibility_status { Litigation::VISIBILITY.first }
  end
end
