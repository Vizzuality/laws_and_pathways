# == Schema Information
#
# Table name: litigations
#
#  id                        :bigint           not null, primary key
#  title                     :string           not null
#  slug                      :string           not null
#  citation_reference_number :string
#  document_type             :string
#  location_id               :bigint
#  jurisdiction_id           :bigint
#  summary                   :text
#  core_objective            :text
#  keywords                  :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  created_by_id             :bigint
#  updated_by_id             :bigint
#

class Litigation < ApplicationRecord
  include UserTrackable
  include Taggable

  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  DOCUMENT_TYPES = %w[case investigation inquiry].freeze
  VISIBILITY = %w[draft pending published archived].freeze

  enum document_type: array_to_enum_hash(DOCUMENT_TYPES)
  enum visibility_status: array_to_enum_hash(VISIBILITY)

  tag_with :keywords

  belongs_to :location
  belongs_to :jurisdiction, class_name: 'Location'
  has_many :litigation_sides, -> { order(:side_type) }, inverse_of: :litigation
  has_many :documents, as: :documentable, dependent: :destroy
  has_and_belongs_to_many :legislations

  accepts_nested_attributes_for :documents, allow_destroy: true
  accepts_nested_attributes_for :litigation_sides, allow_destroy: true

  validates_presence_of :title, :slug, :document_type, :visibility_status
end
