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
  include UserTrackable
  include Taggable
  include VisibilityStatus
  include DiscardableModel
  include PublicActivityTrackable
  include PgSearch::Model
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  DOCUMENT_TYPES = %w[case administrative_case judicial_case inquiry].freeze
  EVENT_TYPES = %w[
    administrative_objection_dismissed
    administrative_review_dismissed
    alleged_offense_occurred
    amici_curiae_brief_filed
    appeal_dismissed
    application_denied
    application_received
    case_appealed
    case_argued
    case_closed
    case_decided
    case_filed
    case_on_appeal
    case_open
    case_opened
    case_started
    case_dismissed
    case_overruled
    case_referred
    claim_filed
    complaint_amended
    complaint_filed
    contested_policy_adopted
    contested_regulation_issued
    decision_adopted
    disputed_license_is_granted
    exempt_resolution_issued
    external_contribution_filed
    fine_imposed
    first_decision
    first_hearing
    formal_opinion_issued
    license_awarded
    license_denied
    motion_denied
    objection_rejected
    permit_denied
    permit_granted
    permit_requested
    related_law_passed
    related_policy_amended
    request_made
    request_rejected
    retraction_and_apology_issued
    second_appeal_filed
    appeal_filed
    license_issued
    site_visit
    tax_abolished
    withdrawn
  ].freeze
  EVENT_STARTED_TYPES = %w[case_filed case_opened case_started].freeze

  enum document_type: array_to_enum_hash(DOCUMENT_TYPES)

  scope :started, -> { joins(:events).where(events: {event_type: EVENT_STARTED_TYPES}) }
  scope :recent, ->(date = 1.month.ago) { started.where('events.date > ?', date) }

  pg_search_scope :full_text_search,
                  associated_against: {
                    tags: [:name]
                  },
                  against: {
                    title: 'A',
                    summary: 'B'
                  },
                  using: {
                    tsearch: {prefix: true}
                  }

  tag_with :keywords
  tag_with :responses

  belongs_to :geography, optional: true
  has_and_belongs_to_many :laws_sectors
  has_many :litigation_sides, -> { order(:side_type) }, inverse_of: :litigation
  has_many :documents, as: :documentable, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  has_and_belongs_to_many :legislations
  has_and_belongs_to_many :external_legislations

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :documents
    accepts_nested_attributes_for :litigation_sides
    accepts_nested_attributes_for :events
  end

  validates_presence_of :title, :slug, :document_type

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
