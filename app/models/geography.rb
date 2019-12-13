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
  include PublicActivityTrackable
  include PgSearch::Model
  extend FriendlyId

  friendly_id :name, use: :slugged, routes: :default

  EVENT_TYPES = %w[
    declaration_of_climate_emergency
    election
    government_change
    international_agreement
    net_zero_pledge
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

  EU_COUNTRIES = %w[
    AUT BEL BGR CYP CZE DEU DNK ESP EST FIN FRA GBR GRC HRV HUN IRL ITA LTU
    LUX LVA MLT NLD POL PRT ROU SVK SVN SWE
  ].freeze

  enum geography_type: array_to_enum_hash(GEOGRAPHY_TYPES)

  pg_search_scope :full_text_search,
                  associated_against: {tags: [:name]},
                  against: {
                    name: 'A',
                    region: 'B',
                    legislative_process: 'C'
                  },
                  using: {
                    tsearch: {prefix: true}
                  }

  tag_with :political_groups

  has_many :litigations
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

  def eu_member?
    EU_COUNTRIES.include?(iso)
  end

  def all_events
    laws_events = Event.where(eventable_type: 'Legislation')
      .joins('INNER JOIN legislations ON legislations.id = events.eventable_id')
      .where('legislations.geography_id = ?', id)

    litigations_events = Event.where(eventable_type: 'Litigation')
      .joins('INNER JOIN litigations ON litigations.id = events.eventable_id')
      .where('litigations.geography_id = ?', id)

    Event.from("(#{laws_events.to_sql} UNION #{litigations_events.to_sql} UNION #{events.to_sql}) AS events")
      .order(date: :asc)
  end
end
