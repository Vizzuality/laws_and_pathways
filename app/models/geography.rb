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

class Geography < ApplicationRecord
  include UserTrackable
  include Taggable
  include VisibilityStatus
  include DiscardableModel
  extend FriendlyId

  friendly_id :name, use: :slugged, routes: :default

  EVENT_TYPES = %w[
    election
    government_change
    international_agreement
  ].freeze

  GEOGRAPHY_TYPES = %w[
    supranational
    national
    subnational
    local
  ].freeze

  REGIONS = [
    'East Asia & Pacific',
    'South Asia',
    'Europe & Central Asia',
    'Middle East & North Africa',
    'Sub-Saharan Africa',
    'North America',
    'Latin America & Caribbean'
  ].freeze

  enum geography_type: array_to_enum_hash(GEOGRAPHY_TYPES)

  tag_with :political_groups

  has_many :litigations, foreign_key: 'jurisdiction_id'
  has_many :legislations
  has_many :targets
  has_many :events, as: :eventable, dependent: :destroy

  accepts_nested_attributes_for :events, allow_destroy: true, reject_if: :all_blank

  validates_uniqueness_of :slug, :iso
  validates_presence_of :name, :slug, :geography_type
  validates :iso, presence: true, if: :national?
  validates :federal, inclusion: {in: [true, false]}
  validates :region, inclusion: {in: REGIONS}

  def indc_url
    return unless national?

    "https://www4.unfccc.int/sites/NDCStaging/pages/Party.aspx?party=#{iso}"
  end
end
