class Litigation < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  DOCUMENT_TYPES = %w[case investigation inquiry].freeze

  enum document_type: array_to_enum_hash(DOCUMENT_TYPES)

  validates_presence_of :title, :slug
end
