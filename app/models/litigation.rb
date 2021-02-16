# == Schema Information
#
# Table name: litigations
#
#  id                        :bigint           not null, primary key
#  title                     :string           not null
#  slug                      :string           not null
#  citation_reference_number :string
#  document_type             :string
#  geography_id              :bigint
#  summary                   :text
#  at_issue                  :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  created_by_id             :bigint
#  updated_by_id             :bigint
#  discarded_at              :datetime
#  jurisdiction              :string
#

class Litigation < ApplicationRecord
  include Eventable
  include UserTrackable
  include Taggable
  include VisibilityStatus
  include DiscardableModel
  include PublicActivityTrackable
  include PgSearch::Model
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  DOCUMENT_TYPES = %w[case administrative_case judicial_case inquiry].freeze

  EVENT_TYPES = %w[filing dismissed granted appealed settled closed other].freeze
  EVENT_STARTED_TYPES = %w[filing].freeze

  enum document_type: array_to_enum_hash(DOCUMENT_TYPES)

  scope :started, -> { joins(:events).where(events: {event_type: EVENT_STARTED_TYPES}) }
  scope :recent, ->(date = 1.month.ago) { started.where('events.date > ?', date) }

  #  WARNING: make sure you update tsv column when changing against
  #           (against are actually not used when column is in use)
  pg_search_scope :full_text_search,
                  associated_against: {
                    tags: [:name],
                    litigation_sides: [:name],
                    geography: [:name]
                  },
                  against: {
                    title: 'A',
                    summary: 'B'
                  },
                  using: {
                    tsearch: {
                      tsvector_column: 'tsv',
                      prefix: true,
                      dictionary: 'english'
                    }
                  },
                  ignoring: :accents

  tag_with :keywords
  tag_with :responses

  belongs_to :geography
  has_and_belongs_to_many :laws_sectors
  has_many :litigation_sides, -> { order(:side_type) }, inverse_of: :litigation
  has_many :documents, as: :documentable, dependent: :destroy
  has_and_belongs_to_many :legislations
  has_and_belongs_to_many :external_legislations

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :documents
    accepts_nested_attributes_for :litigation_sides
    accepts_nested_attributes_for :events
  end

  validates_presence_of :title, :slug, :document_type

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  def started_event
    events
      .where(event_type: EVENT_STARTED_TYPES)
      .order(:date)
      .first
  end

  def last_non_starting_event
    events.where.not(event_type: EVENT_STARTED_TYPES)
      .order(:date)
      .last
  end

  def events_with_eventable_title
    events
      .joins('INNER JOIN litigations ON litigations.id = events.eventable_id')
      .select('events.*, litigations.title as eventable_title')
  end
end
