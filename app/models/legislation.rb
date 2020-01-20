# == Schema Information
#
# Table name: legislations
#
#  id                :bigint           not null, primary key
#  title             :string
#  description       :text
#  law_id            :integer
#  slug              :string           not null
#  geography_id      :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  visibility_status :string           default("draft")
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  discarded_at      :datetime
#  legislation_type  :string           not null
#  parent_id         :bigint
#

class Legislation < ApplicationRecord
  include UserTrackable
  include Taggable
  include VisibilityStatus
  include DiscardableModel
  include PublicActivityTrackable
  include PgSearch::Model
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  LEGISLATION_TYPES = %w[executive legislative].freeze
  EVENT_TYPES = %w[
    amended
    approved
    deadline_for_regulation
    decree_passed
    document_amended
    document_passed
    document_approved
    endorsement
    entry_into_force
    executive_decree_issued
    federal_decree_issued
    first_phase_approved
    last_amended
    last_amendment
    law_amended
    law_passed
    law_published
    law_adopted
    ordinance_issued
    plan_adopted
    policy_revised
    regulation_issued
    repealed_and_replaced
    replaced
    start_of_reporting_period
    wholly_amended
  ].freeze

  tag_with :frameworks
  tag_with :document_types
  tag_with :keywords
  tag_with :natural_hazards
  tag_with :responses

  enum legislation_type: array_to_enum_hash(LEGISLATION_TYPES)

  belongs_to :geography
  belongs_to :parent, class_name: 'Legislation', foreign_key: 'parent_id', optional: true
  has_many :documents, as: :documentable, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  has_and_belongs_to_many :targets
  has_and_belongs_to_many :litigations
  has_and_belongs_to_many :instruments
  has_and_belongs_to_many :governances
  has_and_belongs_to_many :laws_sectors

  scope :laws, -> { legislative }
  scope :policies, -> { executive }
  scope :passed, -> { joins(:events).where(events: {event_type: 'law_passed'}) }
  scope :recent, ->(date = 1.month.ago) { passed.where('events.date > ?', date) }

  pg_search_scope :full_text_search,
                  associated_against: {
                    tags: [:name]
                  },
                  against: {
                    title: 'A',
                    description: 'B'
                  },
                  using: {
                    tsearch: {prefix: true}
                  }

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :documents
    accepts_nested_attributes_for :events
  end

  validates_presence_of :title, :slug
  validates_uniqueness_of :slug

  def law?
    legislative?
  end

  def policy?
    executive?
  end

  def events_with_eventable_title
    events
      .joins('INNER JOIN legislations ON legislations.id = events.eventable_id')
      .select('events.*, legislations.title as eventable_title')
  end

  def date_passed
    events.where(event_type: 'law_passed').first&.date
  end

  def first_event
    events.order(:date).first
  end

  def last_event
    events.order(:date).offset(1).last
  end
end
