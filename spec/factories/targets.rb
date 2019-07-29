# == Schema Information
#
# Table name: targets
#
#  id               :bigint           not null, primary key
#  location_id      :bigint
#  sector_id        :bigint
#  legislation_id   :bigint
#  ghg_target       :boolean          default(FALSE), not null
#  type             :string           not null
#  description      :text
#  year             :integer
#  base_year_period :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryBot.define do
  factory :target do
    association :location
    association :sector
    association :legislation

    description { 'Target description' }
    year { 2023 }
    type { 'single_year' }
  end
end
