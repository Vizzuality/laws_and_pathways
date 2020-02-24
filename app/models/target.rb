# == Schema Information
#
# Table name: targets
#
#  id                :bigint           not null, primary key
#  geography_id      :bigint
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
#  sector_id         :bigint
#  source            :string
#

class Target < ApplicationRecord
  include UserTrackable
  include VisibilityStatus
  include DiscardableModel
  include PublicActivityTrackable
  include PgSearch::Model
  include Taggable

  TYPES = %w[
    base_year_target
    baseline_scenario_target
    fixed_level_target
    intensity_target
    intensity_target_and_trajectory_target
    no_document_submitted
    trajectory_target
    not_applicable
  ].freeze

  EVENT_TYPES = %w[
    set
    updated
    met
  ].freeze

  SOURCES = %w[
    framework
    law
    ndc
    plan
    policy
    strategy
  ].freeze

  tag_with :scopes

  enum target_type: array_to_enum_hash(TYPES)
  enum source: array_to_enum_hash(SOURCES)

  belongs_to :geography
  belongs_to :sector, class_name: 'LawsSector', foreign_key: 'sector_id'
  has_many :events, as: :eventable, dependent: :destroy
  has_and_belongs_to_many :legislations

  scope :recent, ->(date = 1.month.ago) {
    joins(:events)
      .where('events.date > ?', date)
      .where(events: {event_type: %w[set updated]})
  }
  scope :with_id_order, ->(ids) {
    order = sanitize_sql_array(['array_position(ARRAY[?]::int[], targets.id::int)', ids])
    order(order)
  }

  pg_search_scope :full_text_search,
                  associated_against: {
                    tags: [:name]
                  },
                  against: [:description],
                  using: {
                    tsearch: {
                      prefix: true,
                      dictionary: 'english'
                    }
                  },
                  ignoring: :accents

  accepts_nested_attributes_for :events, allow_destroy: true, reject_if: :all_blank

  validates :ghg_target, inclusion: {in: [true, false]}
  validates :single_year, inclusion: {in: [true, false]}

  def to_s
    parts = [geography.name, target_type&.humanize, year]
    parts.compact.join(' - ')
  end
end
