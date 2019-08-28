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
#  jurisdiction_id           :bigint
#  summary                   :text
#  core_objective            :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  created_by_id             :bigint
#  updated_by_id             :bigint
#

class Litigation < ApplicationRecord
  include UserTrackable
  include Taggable
  include Publishable
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  DOCUMENT_TYPES = %w[case investigation inquiry].freeze
  EVENT_TYPES = %w[
    case_started
    case_dismissed
    case_overruled
    case_decided
  ].freeze

  enum document_type: array_to_enum_hash(DOCUMENT_TYPES)

  tag_with :keywords

  belongs_to :geography
  belongs_to :jurisdiction, class_name: 'Geography'
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
end
