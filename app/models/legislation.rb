class Legislation < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  FRAMEWORKS = %w[mitigation adaptation mitigation_and_adaptation no].freeze
  enum framework: array_to_enum_hash(FRAMEWORKS)

  belongs_to :location

  validates_presence_of :title, :framework, :slug
  validates_uniqueness_of :slug
end
