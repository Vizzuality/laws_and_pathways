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
#  indc_url                   :text
#

class Geography < ApplicationRecord
  include UserTrackable
  include Taggable
  include Publishable
  extend FriendlyId

  friendly_id :name, use: :slugged, routes: :default

  TYPES = %w[country].freeze

  REGIONS = [
    'East Asia & Pacific',
    'South Asia',
    'Europe & Central Asia',
    'Middle East & North Africa',
    'Sub-Saharan Africa',
    'North America',
    'Latin America & Caribbean'
  ].freeze

  enum geography_type: array_to_enum_hash(TYPES)

  tag_with :political_groups

  has_many :litigations

  validates_uniqueness_of :slug, :iso
  validates_presence_of :name, :slug, :iso, :geography_type
  validates :federal, inclusion: {in: [true, false]}
  validates :region, inclusion: {in: REGIONS}
  validates :indc_url, url: true
end
