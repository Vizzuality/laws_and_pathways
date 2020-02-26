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
  include Eventable
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
                  against: {
                    name: 'A',
                    region: 'B'
                  },
                  using: {
                    trigram: {
                      word_similarity: true,
                      threshold: 0.5
                    }
                  }

  tag_with :political_groups

  has_many :litigations
  has_many :legislations
  has_many :targets

  accepts_nested_attributes_for :events, allow_destroy: true, reject_if: :all_blank

  validates_uniqueness_of :slug, :iso
  validates_presence_of :name, :slug, :geography_type
  validates :iso, presence: true, if: :national?
  validates :federal, inclusion: {in: [true, false]}
  validates :region, inclusion: {in: REGIONS}

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def indc_url
    return unless national?

    "https://www4.unfccc.int/sites/NDCStaging/pages/Party.aspx?party=#{iso}"
  end

  def eu_member?
    EU_COUNTRIES.include?(iso)
  end

  def events_with_eventable_title
    events
      .joins('INNER JOIN geographies ON geographies.id = events.eventable_id')
      .select('events.*, geographies.name as eventable_title')
  end

  def self_and_related_events
    laws_events = Event.where(eventable_type: 'Legislation')
      .joins('INNER JOIN legislations ON legislations.id = events.eventable_id')
      .select('events.*, legislations.title as eventable_title')
      .where('legislations.geography_id = ?', id)

    litigations_events = Event.where(eventable_type: 'Litigation')
      .joins('INNER JOIN litigations ON litigations.id = events.eventable_id')
      .select('events.*, litigations.title as eventable_title')
      .where('litigations.geography_id = ?', id)

    Event
      .from(
        "(#{laws_events.to_sql}
        UNION #{litigations_events.to_sql}
        UNION #{events_with_eventable_title.to_sql})
        AS events"
      )
      .order(date: :asc)
  end

  def self.eu_ndc_targets
    eu = Geography.find_by(iso: 'EUR')
    eu.targets.published.where(source: 'ndc')
  end

  # rubocop:disable Metrics/AbcSize
  def laws_per_sector
    targets.group_by(&:sector).map do |sector, targets|
      {
        sector: sector&.name,
        ndc_targets_count:
          if eu_member?
            Geography.eu_ndc_targets.select { |target| target.sector.eql?(sector) }.count
          else
            targets.select { |t| t.source && t.source.downcase == 'ndc' }.count
          end,
        law_targets_count: targets.select { |t| t.source && t.source.downcase == 'law' }.count,
        policy_targets_count: targets.select { |t| t.source && t.source.downcase == 'policy' }.count
      }
    end
  end
  # rubocop:enable Metrics/AbcSize
end
