class Litigation < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  DOCUMENT_TYPES = %w[case investigation inquiry].freeze

  enum document_type: array_to_enum_hash(DOCUMENT_TYPES)

  belongs_to :location

  validates_presence_of :title, :slug, :document_type
end
