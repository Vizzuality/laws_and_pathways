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
  include Eventable
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
    entered_into_force
    implementation_details
    passed/approved
    repealed/replaced
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
  has_and_belongs_to_many :targets
  has_and_belongs_to_many :litigations
  has_and_belongs_to_many :instruments
  has_and_belongs_to_many :governances
  has_and_belongs_to_many :laws_sectors

  scope :laws, -> { legislative }
  scope :policies, -> { executive }
  scope :passed, -> { joins(:events).where(events: {event_type: 'passed/approved'}) }
  scope :recent, ->(date = 1.month.ago) { passed.where('events.date > ?', date) }

  pg_search_scope :full_text_search,
                  associated_against: {
                    tags: [:name],
                    geography: [:name]
                  },
                  against: {
                    title: 'A',
                    description: 'B'
                  },
                  using: {
                    tsearch: {
                      prefix: true,
                      dictionary: 'english'
                    }
                  },
                  ignoring: :accents

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :documents
    accepts_nested_attributes_for :events
  end

  validates_presence_of :title, :slug, :legislation_type
  validates_uniqueness_of :slug

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  def law?
    legislative?
  end

  def policy?
    executive?
  end

  def display_name
    ["#{title} (id: #{id})", geography&.name].join(' | ')
  end

  def events_with_eventable_title
    events
      .joins('INNER JOIN legislations ON legislations.id = events.eventable_id')
      .select('events.*, legislations.title as eventable_title')
  end

  def date_passed
    events.find_by(event_type: 'passed/approved')&.date
  end

  def first_event
    events.order(:date).first
  end

  def last_event
    events.order(:date).offset(1).last
  end

  def url
    Rails.application.routes.url_helpers.send("cclow_geography_#{law? ? 'law' : 'policy'}_url",
                                              geography.slug, slug,
                                              host: 'climate-laws.org')
  end
end
