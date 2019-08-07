# == Schema Information
#
# Table name: locations
#
#  id                         :bigint           not null, primary key
#  location_type              :string           not null
#  iso                        :string           not null
#  name                       :string           not null
#  slug                       :string           not null
#  region                     :string           not null
#  federal                    :boolean          default(FALSE), not null
#  federal_details            :text
#  approach_to_climate_change :text
#  legislative_process        :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  visibility_status          :string           default("draft")
#

FactoryBot.define do
  factory :location do
    sequence(:name) { |n| 'name-' + ('AA'..'ZZ').to_a[n] }
    sequence(:iso) { |n| ('AAA'..'ZZZ').to_a[n] }

    location_type { 'country' }
    region { Location::REGIONS.sample }
    visibility_status { Litigation::VISIBILITY.sample }
    federal { false }

    association :created_by, factory: :admin_user
    association :updated_by, factory: :admin_user
  end
end
