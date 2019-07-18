# == Schema Information
#
# Table name: locations
#
#  id                         :bigint(8)        not null, primary key
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
#

class Location < ApplicationRecord
  include Taggable
  extend FriendlyId

  friendly_id :name, use: :slugged

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

  enum location_type: array_to_enum_hash(TYPES)

  tag_with :political_groups

  has_many :litigations

  validates_uniqueness_of :slug, :iso
  validates_presence_of :name, :slug, :iso, :location_type
  validates :federal, inclusion: {in: [true, false]}
  validates :region, inclusion: {in: REGIONS}
end
